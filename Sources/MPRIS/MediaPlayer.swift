import DBus

extension BusName {
  /// The well-known name prefix for the media player.
  public static let mediaPlayer2Prefix: String = "org.mpris.MediaPlayer2"

  /// Creates a bus name for the media player.
  ///
  /// - Parameters:
  ///   - name: The name of the media player.
  ///   - instance: The instance of the media player.
  /// - Returns: The bus name for the media player.
  public static func mediaPlayer2(name: String, instance: String? = nil) -> BusName {
    if let instance {
      .init(rawValue: "\(mediaPlayer2Prefix).\(name).\(instance)")
    } else {
      .init(rawValue: "\(mediaPlayer2Prefix).\(name)")
    }
  }
}

extension ObjectPath {
  /// The object path for the media player.
  public static let mediaPlayer2: ObjectPath = "/org/mpris/MediaPlayer2"
}

extension InterfaceName {
  /// The interface name for the media player.
  public static let mediaPlayer2: InterfaceName = "org.mpris.MediaPlayer2"
  /// The interface name for the media player's player.
  public static let mediaPlayer2Player: InterfaceName = "org.mpris.MediaPlayer2.Player"
  /// The interface name for the media player's track list.
  public static let mediaPlayer2TrackList: InterfaceName = "org.mpris.MediaPlayer2.TrackList"
  /// The interface name for the media player's playlists.
  public static let mediaPlayer2Playlists: InterfaceName = "org.mpris.MediaPlayer2.Playlists"
}

/// Represents a `MPRIS` media player.
/// See: https://specifications.freedesktop.org/mpris-spec/latest/
public struct MediaPlayer2 {
  /// The bus name of the media player.
  public let busName: BusName
  /// The player of the media player.
  public let player: Player
  /// The track list of the media player.
  public let trackList: TrackList
  /// The playlists of the media player.
  public let playlists: Playlists

  let object: ObjectProxy
  let methods: MethodsProxy
  let properties: PropertiesProxy
}

extension MediaPlayer2 {
  /// Initializes a new media player.
  ///
  /// - Parameters:
  ///   - connection: The connection to the D-Bus.
  ///   - busName: The bus name of the media player.
  ///   - timeout: The timeout interval for the method calls.
  public init(
    connection: Connection, busName: BusName,
    timeout: TimeoutInterval = .useDefault
  ) {
    self.busName = busName
    object = ObjectProxy(
      connection: connection,
      destination: busName,
      path: .mediaPlayer2,
      timeout: timeout
    )
    methods = object.methods(interface: .mediaPlayer2)
    properties = object.properties(interface: .mediaPlayer2)
    player = Player(
      methods: object.methods(interface: .mediaPlayer2Player),
      properties: object.properties(interface: .mediaPlayer2Player),
      signals: object.signals(interface: .mediaPlayer2Player)
    )
    trackList = TrackList(
      methods: object.methods(interface: .mediaPlayer2TrackList),
      properties: object.properties(interface: .mediaPlayer2TrackList),
      signals: object.signals(interface: .mediaPlayer2TrackList)
    )
    playlists = Playlists(
      methods: object.methods(interface: .mediaPlayer2Playlists),
      properties: object.properties(interface: .mediaPlayer2Playlists),
      signals: object.signals(interface: .mediaPlayer2Playlists)
    )
  }

  /// Initializes a new media player.
  ///
  /// - Parameters:
  ///   - connection: The connection to the D-Bus.
  ///   - name: The name of the media player.
  ///   - instance: The instance of the media player.
  ///   - timeout: The timeout interval for the method calls.
  public init(
    connection: Connection,
    name: String, instance: String? = nil,
    timeout: TimeoutInterval = .useDefault
  ) {
    self.init(
      connection: connection,
      busName: .mediaPlayer2(name: name, instance: instance),
      timeout: timeout
    )
  }
}

extension MediaPlayer2 {
  /// Brings the media player's user interface to the front using any appropriate mechanism available.
  /// The media player may be unable to control how its user interface is displayed,
  /// or it may not have a graphical user interface at all.
  /// In this case, the `canRaise` property is false and this method does nothing.
  public func raise() throws(DBus.Error) {
    try methods.Raise() as Void
  }

  /// Async version of `raise`.
  @available(macOS 10.15.0, *)
  public func raise() async throws(DBus.Error) {
    try await methods.Raise() as Void
  }

  /// Causes the media player to stop running.
  /// The media player may refuse to allow clients to shut it down.
  /// In this case, the `canQuit` property is false and this method does nothing.
  ///
  /// Note: Media players which can be D-Bus activated,
  /// or for which there is no sensibly easy way to terminate a running instance
  /// (via the main interface or a notification area icon for example)
  /// should allow clients to use this method. Otherwise, it should not be needed.
  /// If the media player does not have a UI, this should be implemented.
  public func quit() throws(DBus.Error) {
    try methods.Quit() as Void
  }

  /// Async version of `quit`.
  @available(macOS 10.15.0, *)
  public func quit() async throws(DBus.Error) {
    try await methods.Quit() as Void
  }

  /// If false, calling `quit` will have no effect, and may raise a `NotSupported` error.
  /// If true, calling `quit` will cause the media application to attempt to quit
  /// (although it may still be prevented from quitting by the user, for example).
  public var canQuit: some ObservableReadOnlyProperty<Bool> {
    properties.CanQuit
  }

  /// Whether the media player is occupying the fullscreen.
  /// This is typically used for videos. A value of true indicates that the media player is taking up the full screen.
  /// Media centre software may well have this value fixed to true.
  /// If `canSetFullscreen` is true, clients may set this property to true to tell the media player to enter fullscreen mode,
  /// or to false to return to windowed mode.
  /// If `canSetFullscreen` is false, then attempting to set this property should have no effect, and may raise an error.
  /// However, even if it is true, the media player may still be unable to fulfil the request,
  /// in which case attempting to set this property will have no effect (but should not raise an error).
  ///
  /// Rationale:
  /// This allows remote control interfaces, such as LIRC or mobile devices like phones,
  /// to control whether a video is shown in fullscreen.
  public var fullscreen: some ObservableReadWriteProperty<Bool> {
    properties.Fullscreen
  }

  /// If false, attempting to set `fullscreen` will have no effect, and may raise an error.
  /// If true, attempting to set `fullscreen` will not raise an error,
  /// and (if it is different from the current value) will cause the media player to attempt to enter or exit fullscreen mode.
  /// Note that the media player may be unable to fulfil the request.
  /// In this case, the value will not change.
  /// If the media player knows in advance that it will not be able to fulfil the request, however, this property should be false.
  public var canSetFullscreen: some ObservableReadOnlyProperty<Bool> {
    properties.CanSetFullscreen
  }

  /// If false, calling `raise` will have no effect, and may raise a `NotSupported` error.
  /// If true, calling `raise` will cause the media application to attempt to bring its user interface to the front,
  /// although it may be prevented from doing so (by the window manager, for example).
  public var canRaise: some ObservableReadOnlyProperty<Bool> {
    properties.CanRaise
  }

  /// Indicates whether the `/org/mpris/MediaPlayer2` object implements the `org.mpris.MediaPlayer2.TrackList` interface.
  public var hasTrackList: some ObservableReadOnlyProperty<Bool> {
    properties.HasTrackList
  }

  /// A friendly name to identify the media player to users.
  /// This should usually match the name found in `.desktop` files.
  public var identity: some ObservableReadOnlyProperty<String> {
    properties.Identity
  }

  /// The basename of an installed `.desktop` file which complies with the Desktop entry specification, with the `.desktop` extension stripped.
  /// Example: The desktop entry file is `/usr/share/applications/vlc.desktop`, and this property contains `vlc`.
  public var desktopEntry: some ObservableReadOnlyProperty<String> {
    properties.DesktopEntry
  }

  /// The URI schemes supported by the media player.
  /// This can be viewed as protocols supported by the player in almost all cases.
  /// Almost every media player will include support for the `file` scheme.
  /// Other common schemes are `http` and `rtsp`.
  /// Note that URI schemes should be lower-case.
  ///
  /// Rationale:
  /// This is important for clients to know when using the editing capabilities of the `Playlist` interface, for example.
  public var supportedUriSchemes: some ObservableReadOnlyProperty<[String]> {
    properties.SupportedUriSchemes
  }

  /// The mime-types supported by the media player.
  /// Mime-types should be in the standard format (e.g., `audio/mpeg` or `application/ogg`).
  ///
  /// Rationale:
  /// This is important for clients to know when using the editing capabilities of the `Playlist` interface, for example.
  public var supportedMimeTypes: some ObservableReadOnlyProperty<[String]> {
    properties.SupportedMimeTypes
  }
}
