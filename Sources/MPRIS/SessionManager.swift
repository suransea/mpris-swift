import DBus
import Foundation

extension MediaPlayer2 {
  /// The `SessionManager` class is responsible for managing multiple
  /// instances of `MediaPlayer2` and handling their state changes.
  public class SessionManager {
    private var cancellables: [BusName: [() throws -> Void]] = [:]
    private var playersChangedObservers: [UUID: ([MediaPlayer2]) -> Void] = [:]
    private var activePlayerChangedObservers: [UUID: (MediaPlayer2?) -> Void] = [:]

    /// A list of current media players.
    public private(set) var players: [MediaPlayer2] = [] {
      didSet {
        playersChangedObservers.values.forEach { $0(players) }
      }
    }

    /// The active player, i.e. the player that is currently playing.
    public var activePlayer: MediaPlayer2? {
      didSet {
        activePlayerChangedObservers.values.forEach { $0(activePlayer) }
      }
    }

    deinit {
      cancellables.values.forEach { $0.forEach { try? $0() } }
    }

    /// Observes the list of media players for changes.
    ///
    /// - Parameter observer: The observer to be called when the list of media players changes.
    /// - Returns: A function that unregisters the observer.
    public func observePlayers(
      _ observer: @escaping ([MediaPlayer2]) -> Void
    ) -> () -> Void {
      let id = UUID()
      playersChangedObservers[id] = observer
      return { self.playersChangedObservers.removeValue(forKey: id) }
    }

    /// Observes the active player for changes.
    ///
    /// - Parameter observer: The observer to be called when the active player changes.
    /// - Returns: A function that unregisters the observer.
    public func observeActivePlayer(
      _ observer: @escaping (MediaPlayer2?) -> Void
    ) -> () -> Void {
      let id = UUID()
      activePlayerChangedObservers[id] = observer
      return { self.activePlayerChangedObservers.removeValue(forKey: id) }
    }
  }
}

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
