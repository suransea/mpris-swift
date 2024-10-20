import DBus
import Foundation
import Observation

extension MediaPlayer2 {
  /// The `SessionManager` class is responsible for managing multiple
  /// instances of `MediaPlayer2` and handling their state changes.
  @Observable
  @available(macOS 14.0, *)
  public class SessionManager {
    @ObservationIgnored
    private var cancellables: [BusName: [() throws -> Void]] = [:]

    /// A list of current media players.
    public private(set) var players: [MediaPlayer2] = []

    /// The active player, i.e. the player that is currently playing.
    public private(set) var activePlayer: MediaPlayer2?

    deinit {
      cancellables.values.forEach { $0.forEach { try? $0() } }
    }
  }
}

@available(macOS 14.0, *)
extension MediaPlayer2.SessionManager {
  /// Initializes a new session manager.
  ///
  /// - Parameters:
  ///   - connection: The D-Bus connection to use.
  ///   - timeout: The timeout interval for D-Bus operations.
  /// - Throws: An error if cannot setup the manager.
  public convenience init(
    connection: Connection, timeout: TimeoutInterval = .useDefault
  ) throws {
    self.init()
    let bus = Bus(connection: connection, timeout: timeout)
    let disconnect = try bus.nameOwnerChanged { [weak self] (name, oldOwner, newOwner) in
      guard let self = self else { return }
      guard name.rawValue.hasPrefix(BusName.mediaPlayer2Prefix) else { return }
      if oldOwner.rawValue.isEmpty {
        try? self.add(player: MediaPlayer2(connection: connection, busName: name, timeout: timeout))
      }
      if newOwner.rawValue.isEmpty {
        self.remove(player: name)
      }
    }
    cancellables[.bus, default: []].append(disconnect)
    let names = try bus.listNames()
    let players =
      names
      .filter { name in name.rawValue.hasPrefix(BusName.mediaPlayer2Prefix) }
      .map { name in MediaPlayer2(connection: connection, busName: name, timeout: timeout) }
    try players.forEach(add)
  }

  /// Retrieves the last media player with the specified playback status.
  ///
  /// - Parameter status: The desired playback status to match.
  /// - Returns: The last `MediaPlayer2` instance that matches the given playback status, or `nil` if no match is found.
  private func lastPlayer(status: PlaybackStatus) -> MediaPlayer2? {
    players.last { player in
      (try? player.player.playbackStatus.get()) == status
    }
  }

  /// Adds a new media player to the manager.
  ///
  /// - Parameter player: The media player to add.
  /// - Throws: An error if cannot setup the player.
  private func add(player: MediaPlayer2) throws {
    let onPlaybackStatusChanged = { [weak self] (status: PlaybackStatus) in
      guard let self = self else { return }
      if activePlayer == nil {
        activePlayer = player
        return
      }
      if player.busName == activePlayer?.busName {
        if status != .playing, let playingPlayer = lastPlayer(status: .playing) {
          activePlayer = playingPlayer
        }
        return
      }
      let activePlayerStatus = {
        try? self.activePlayer?.player.playbackStatus.get()
      }
      if status == .playing && activePlayerStatus() != .playing {
        activePlayer = player
      }
    }
    onPlaybackStatusChanged(try player.player.playbackStatus.get())
    let cancel = try player.player.playbackStatus.observe(onPlaybackStatusChanged)
    cancellables[player.busName, default: []].append(cancel)
    players.append(player)
  }

  /// Removes a media player from the manager.
  ///
  /// - Parameter busName: The bus name of the media player to remove.
  private func remove(player busName: BusName) {
    if let index = players.firstIndex(where: { $0.busName == busName }) {
      players.remove(at: index)
    }
    cancellables.removeValue(forKey: busName)?.forEach { try? $0() }
    if activePlayer?.busName == busName {
      activePlayer = lastPlayer(status: .playing) ?? lastPlayer(status: .paused) ?? players.last
    }
  }
}
