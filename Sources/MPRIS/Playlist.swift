import DBus

extension MediaPlayer2 {
  /// Provides access to the media player's playlists.
  ///
  /// Since `D-Bus` does not provide an easy way to check for what interfaces
  /// are exported on an object, clients should attempt to get one of the
  /// properties on this interface to see if it is implemented.
  public struct Playlists {
    let methods: MethodsProxy
    let properties: PropertiesProxy
    let signals: SignalsProxy
  }
}

extension MediaPlayer2.Playlists {
  /// Starts playing the given playlist.
  /// Note that this must be implemented. If the media player does not
  /// allow clients to change the playlist, it should not implement this
  /// interface at all. It is up to the media player whether this
  /// completely replaces the current tracklist, or whether it is merely
  /// inserted into the tracklist and the first track starts. For example,
  /// if the media player is operating in a "jukebox" mode, it may just
  /// append the playlist to the list of upcoming tracks, and skip to the
  /// first track in the playlist.
  ///
  /// - Parameter playlistId: The id of the playlist to activate.
  public func activatePlaylist(playlistId: PlaylistId) throws {
    try methods.ActivatePlaylist(playlistId) as Void
  }

  /// Async version of `activatePlaylist`.
  @available(macOS 10.15.0, *)
  public func activatePlaylist(playlistId: PlaylistId) async throws {
    try await methods.ActivatePlaylist(playlistId) as Void
  }

  /// Gets a set of playlists.
  ///
  /// - Parameters:
  ///   - index: The index of the first playlist to be fetched (according
  ///   to the ordering).
  ///   - maxCount: The maximum number of playlists to fetch.
  ///   - order: The ordering that should be used.
  ///   - reverseOrder: Whether the order should be reversed.
  /// - Returns: A list of (at most `maxCount`) playlists.
  public func getPlaylists(
    index: UInt32, maxCount: UInt32, order: PlaylistOrdering, reverseOrder: Bool
  ) throws -> [Playlist] {
    try methods.GetPlaylists(index, maxCount, order, reverseOrder)
  }

  /// Async version of `getPlaylists`.
  @available(macOS 10.15.0, *)
  public func getPlaylists(
    index: UInt32, maxCount: UInt32, order: PlaylistOrdering, reverseOrder: Bool
  ) async throws -> [Playlist] {
    try await methods.GetPlaylists(index, maxCount, order, reverseOrder)
  }

  /// Indicates that either the `name` or `icon` attribute of a playlist
  /// has changed. Client implementations should be aware that this signal
  /// may not be implemented.
  ///
  /// - Parameter handler: The handler to be called when the signal is
  /// emitted.
  /// - Returns: A function that unregisters the handler.
  public func playlistChanged(
    _ handler: @escaping (_ playlist: Playlist) -> Void
  ) throws(DBus.Error) -> () throws(DBus.Error) -> Void {
    try signals.PlaylistChanged.connect(handler)
  }

  /// The number of playlists available.
  public var playlistCount: some ObservableReadOnlyProperty<UInt32> {
    properties.PlaylistCount
  }

  /// The available orderings. At least one must be offered.
  /// Rationale:
  /// Media players may not have access to all the data required for some
  /// orderings. For example, creation times are not available on UNIX
  /// filesystems (don't let the ctime fool you!). On the other hand,
  /// clients should have some way to get the "most recent" playlists.
  public var orderings: some ObservableReadOnlyProperty<[PlaylistOrdering]> {
    properties.Orderings
  }

  /// The currently-active playlist.
  /// If there is no currently-active playlist, the structure's `valid`
  /// field will be false, and the playlist details are undefined. Note
  /// that this may not have a value even after `activatePlaylist` is
  /// called with a valid playlist id as `activatePlaylist` implementations
  /// have the option of simply inserting the contents of the playlist
  /// into the current tracklist.
  public var activePlaylist: some ObservableReadOnlyProperty<OptionalPlaylist> {
    properties.ActivePlaylist
  }
}

/// Unique playlist identifier.
/// Rationale:
/// Multiple playlists may have the same name.
/// This is a D-Bus object id as that is the definitive way to have unique
/// identifiers on D-Bus. It also allows for future optional expansions to
/// the specification where tracks are exported to D-Bus with an interface
/// similar to `org.gnome.UPnP.MediaItem2`.
public typealias PlaylistId = ObjectPath

/// Specifies the ordering of returned playlists.
public enum PlaylistOrdering: String {
  /// Alphabetical ordering by name, ascending.
  case alphabetical = "Alphabetical"
  /// Ordering by creation date, oldest first.
  case creationDate = "Created"
  /// Ordering by last modified date, oldest first.
  case modifiedDate = "Modified"
  /// Ordering by date of last playback, oldest first.
  case lastPlayDate = "Played"
  /// A user-defined ordering.
  ///
  /// Rationale:
  /// Some media players may allow users to order playlists as they wish.
  /// This ordering allows playlists to be retrieved in that order.
  case userDefined = "User"
}

extension PlaylistOrdering: Argument {
  public static var type: ArgumentType { .string }

  public init(from iter: inout MessageIterator) throws(DBus.Error) {
    self.init(rawValue: try String(from: &iter))!
  }

  public func append(to iter: inout MessageIterator) throws(Error) {
    try rawValue.append(to: &iter)
  }
}

/// A data structure describing a playlist.
public struct Playlist {
  /// A unique identifier for the playlist.
  /// This should remain the same if the playlist is renamed.
  public let id: PlaylistId
  /// The name of the playlist, typically given by the user.
  public let name: String
  /// The URI of an (optional) icon.
  public let icon: Uri

  /// Initializes a new playlist.
  /// - Parameters:
  ///   - id: A unique identifier for the playlist.
  ///   - name: The name of the playlist.
  ///   - icon: The URI of an (optional) icon.
  public init(id: PlaylistId, name: String, icon: Uri = "") {
    self.id = id
    self.name = name
    self.icon = icon
  }
}

extension Playlist: Argument {
  public static var type: ArgumentType { .struct }

  public static var signature: Signature { .struct(PlaylistId.self, String.self, Uri.self) }

  public init(from iter: inout MessageIterator) throws(DBus.Error) {
    try iter.checkArgumentType(.struct)
    var subIter = try iter.nextContainer()
    id = try PlaylistId(from: &subIter)
    name = try String(from: &subIter)
    icon = try Uri(from: &subIter)
  }

  public func append(to iter: inout MessageIterator) throws(DBus.Error) {
    try iter.appendContainer(type: .struct) { subIter throws(DBus.Error) in
      try id.append(to: &subIter)
      try name.append(to: &subIter)
      try icon.append(to: &subIter)
    }
  }
}

/// A data structure describing a playlist, or nothing.
/// Rationale:
/// D-Bus does not (at the time of writing) support a MAYBE type, so we
/// are forced to invent our own.
public struct OptionalPlaylist {
  /// The playlist.
  public let playlist: Playlist?

  /// Initializes a new optional playlist.
  /// - Parameter playlist: The playlist.
  public init(_ playlist: Playlist?) {
    self.playlist = playlist
  }
}

extension OptionalPlaylist: Argument {
  public static var type: ArgumentType { .struct }

  public static var signature: Signature { .struct(Bool.self, Playlist.self) }

  public init(from iter: inout MessageIterator) throws(DBus.Error) {
    try iter.checkArgumentType(.struct)
    var subIter = try iter.nextContainer()
    let valid = try Bool(from: &subIter)
    self.init(valid ? try Playlist(from: &subIter) : nil)
  }

  public func append(to iter: inout MessageIterator) throws(DBus.Error) {
    try iter.appendContainer(type: .struct) { subIter throws(DBus.Error) in
      try (playlist != nil).append(to: &subIter)
      try (playlist ?? .init(id: .init(rawValue: "/"), name: "")).append(to: &subIter)
    }
  }
}
