import DBus

extension MediaPlayer2 {
  /// This interface implements the methods for querying and providing basic
  /// control over what is currently playing.
  public struct Player {
    let methods: MethodsProxy
    let properties: PropertiesProxy
    let signals: SignalsProxy
  }
}

extension MediaPlayer2.Player {
  /// Skips to the next track in the tracklist.
  /// If there is no next track (and endless playback and track repeat
  /// are both off), stop playback. If playback is paused or stopped,
  /// it remains that way. If `canGoNext` is false, attempting to call
  /// this method should have no effect.
  public func next() throws(DBus.Error) {
    try methods.Next() as Void
  }

  /// Async version of `next`.
  @available(macOS 10.15.0, *)
  public func next() async throws(DBus.Error) {
    try await methods.Next() as Void
  }

  /// Skips to the previous track in the tracklist.
  /// If there is no previous track (and endless playback and track
  /// repeat are both off), stop playback. If playback is paused or
  /// stopped, it remains that way. If `canGoPrevious` is false,
  /// attempting to call this method should have no effect.
  public func previous() throws(DBus.Error) {
    try methods.Previous() as Void
  }

  /// Async version of `previous`.
  @available(macOS 10.15.0, *)
  public func previous() async throws(DBus.Error) {
    try await methods.Previous() as Void
  }

  /// Pauses playback.
  /// If playback is already paused, this has no effect. Calling `play`
  /// after this should cause playback to start again from the same
  /// position. If `canPause` is false, attempting to call this method
  /// should have no effect.
  public func pause() throws(DBus.Error) {
    try methods.Pause() as Void
  }

  /// Async version of `pause`.
  @available(macOS 10.15.0, *)
  public func pause() async throws(DBus.Error) {
    try await methods.Pause() as Void
  }

  /// Pauses playback.
  /// If playback is already paused, resumes playback. If playback is
  /// stopped, starts playback. If `canPause` is false, attempting to
  /// call this method should have no effect and raise an error.
  public func playPause() throws(DBus.Error) {
    try methods.PlayPause() as Void
  }

  /// Async version of `playPause`.
  @available(macOS 10.15.0, *)
  public func playPause() async throws(DBus.Error) {
    try await methods.PlayPause() as Void
  }

  /// Stops playback.
  /// If playback is already stopped, this has no effect. Calling `play`
  /// after this should cause playback to start again from the beginning
  /// of the track. If `canControl` is false, attempting to call this
  /// method should have no effect and raise an error.
  public func stop() throws(DBus.Error) {
    try methods.Stop() as Void
  }

  /// Async version of `stop`.
  @available(macOS 10.15.0, *)
  public func stop() async throws(DBus.Error) {
    try await methods.Stop() as Void
  }

  /// Starts or resumes playback.
  /// If already playing, this has no effect. If paused, playback resumes
  /// from the current position. If there is no track to play, this has
  /// no effect. If `canPlay` is false, attempting to call this method
  /// should have no effect.
  public func play() throws(DBus.Error) {
    try methods.Play() as Void
  }

  /// Async version of `play`.
  @available(macOS 10.15.0, *)
  public func play() async throws(DBus.Error) {
    try await methods.Play() as Void
  }

  /// Seeks forward in the current track by the specified number of
  /// microseconds. A negative value seeks back. If this would mean
  /// seeking back further than the start of the track, the position is
  /// set to 0. If the value passed in would mean seeking beyond the end
  /// of the track, acts like a call to `next`. If the `canSeek` property
  /// is false, this has no effect.
  ///
  /// - Parameter offset: The number of microseconds to seek forward.
  public func seek(offset: Microseconds) throws(DBus.Error) {
    try methods.Seek(offset) as Void
  }

  /// Async version of `seek`.
  @available(macOS 10.15.0, *)
  public func seek(offset: Microseconds) async throws(DBus.Error) {
    try await methods.Seek(offset) as Void
  }

  /// Sets the current track position in microseconds.
  /// If the `position` argument is less than 0, do nothing. If the
  /// `position` argument is greater than the track length, do nothing.
  /// If the `canSeek` property is false, this has no effect.
  ///
  /// - Parameters:
  ///   - trackId: The currently playing track's identifier. If this does
  ///   not match the id of the currently-playing track, the call is
  ///   ignored as "stale". `/org/mpris/MediaPlayer2/TrackList/NoTrack`
  ///   is not a valid value for this argument.
  ///   - position: Track position in microseconds. This must be between
  ///   0 and `<track_length>`.
  public func setPosition(trackId: TrackId, position: Microseconds) throws(DBus.Error) {
    try methods.SetPosition(trackId, position) as Void
  }

  /// Async version of `setPosition`.
  @available(macOS 10.15.0, *)
  public func setPosition(trackId: TrackId, position: Microseconds) async throws(DBus.Error) {
    try await methods.SetPosition(trackId, position) as Void
  }

  /// Opens the URI given as an argument.
  /// If the playback is stopped, starts playing. If the URI scheme or
  /// the mime-type of the URI to open is not supported, this method does
  /// nothing and may raise an error. In particular, if the list of
  /// available URI schemes is empty, this method may not be implemented.
  /// Clients should not assume that the URI has been opened as soon as
  /// this method returns. They should wait until the `mpris:trackid`
  /// field in the `metadata` property changes. If the media player
  /// implements the `TrackList` interface, then the opened track should
  /// be made part of the tracklist, the
  /// `org.mpris.MediaPlayer2.TrackList.TrackAdded` or
  /// `org.mpris.MediaPlayer2.TrackList.TrackListReplaced` signal should
  /// be fired, as well as the
  /// `org.freedesktop.DBus.Properties.PropertiesChanged` signal on the
  /// tracklist interface.
  ///
  /// - Parameter uri: URI of the track to load. Its URI scheme should be
  /// an element of the `org.mpris.MediaPlayer2.SupportedUriSchemes`
  /// property and the mime-type should match one of the elements of the
  /// `org.mpris.MediaPlayer2.SupportedMimeTypes`.
  public func openUri(_ uri: Uri) throws(DBus.Error) {
    try methods.OpenUri(uri) as Void
  }

  /// Async version of `openUri`.
  @available(macOS 10.15.0, *)
  public func openUri(_ uri: Uri) async throws(DBus.Error) {
    try await methods.OpenUri(uri) as Void
  }

  /// Indicates that the track position has changed in a way that is
  /// inconsistent with the current playing state. When this signal is
  /// not received, clients should assume that: When playing, the
  /// position progresses according to the `rate` property. When paused,
  /// it remains constant. This signal does not need to be emitted when
  /// playback starts or when the track changes, unless the track is
  /// starting at an unexpected position. An expected position would be
  /// the last known one when going from `paused` to `playing`, and 0
  /// when going from `stopped` to `playing`.
  ///
  /// - Parameter handler: The signal handler.
  ///   - position: The new track position in microseconds.
  /// - Returns: A function that disconnects the signal handler.
  public func seeked(
    _ handler: @escaping (_ position: Microseconds) -> Void
  ) throws(DBus.Error) -> () throws(DBus.Error) -> Void {
    try signals.Seeked.connect(handler)
  }

  /// The current playback status.
  public var playbackStatus: some ObservableReadOnlyProperty<PlaybackStatus> {
    properties.PlaybackStatus
  }

  /// The current loop / repeat status.
  /// If `canControl` is false, attempting to set this property should
  /// have no effect and raise an error.
  public var loopStatus: some ObservableReadWriteProperty<LoopStatus> {
    properties.LoopStatus
  }

  /// The current playback rate.
  /// The value must fall in the range described by `minimumRate` and
  /// `maximumRate`, and must not be 0.0. If playback is paused, the
  /// `playbackStatus` property should be used to indicate this. A value
  /// of 0.0 should not be set by the client. If it is, the media player
  /// should act as though `pause` was called. If the media player has no
  /// ability to play at speeds other than the normal playback rate, this
  /// must still be implemented, and must return 1.0. The `minimumRate`
  /// and `maximumRate` properties must also be set to 1.0. Not all
  /// values may be accepted by the media player. It is left to media
  /// player implementations to decide how to deal with values they
  /// cannot use; they may either ignore them or pick a "best fit" value.
  /// Clients are recommended to only use sensible fractions or
  /// multiples of 1 (eg: 0.5, 0.25, 1.5, 2.0, etc).
  ///
  /// Rationale:
  /// This allows clients to display (reasonably) accurate progress bars
  /// without having to regularly query the media player for the current
  /// position.
  public var rate: some ObservableReadWriteProperty<PlaybackRate> {
    properties.Rate
  }

  /// A value of false indicates that playback is progressing linearly
  /// through a playlist, while true means playback is progressing
  /// through a playlist in some other order. If `canControl` is false,
  /// attempting to set this property should have no effect and raise an
  /// error.
  public var shuffle: some ObservableReadWriteProperty<Bool> {
    properties.Shuffle
  }

  /// The metadata of the current element.
  /// If there is a current track, this must have a `mpris:trackid` entry
  /// (of D-Bus type "o") at the very least, which contains a D-Bus path
  /// that uniquely identifies this track. See the type documentation for
  /// more details.
  public var metadata: some ObservableReadOnlyProperty<Metadata> {
    properties.Metadata
  }

  /// The volume level.
  /// When setting, if a negative value is passed, the volume should be
  /// set to 0.0.
  public var volume: some ObservableReadWriteProperty<Volume> {
    properties.Volume
  }

  /// The current track position in microseconds, between 0 and the
  /// `mpris:length` metadata entry (see `metadata`).
  ///
  /// Note:
  /// If the media player allows it, the current playback position can be
  /// changed either the `setPosition` method or the `seek` method on
  /// this interface. If this is not the case, the `canSeek` property is
  /// false, and setting this property has no effect and can raise an
  /// error. If the playback progresses in a way that is inconsistent
  /// with the `rate` property, the `seeked` signal is emitted.
  public var position: some ReadOnlyProperty<Microseconds> {
    properties.Position
  }

  /// The minimum value which the `rate` property can take. Clients should
  /// not attempt to set the `rate` property below this value.
  ///
  /// Note:
  /// Even if this value is 0.0 or negative, clients should not attempt
  /// to set the `rate` property to 0.0. This value should always be 1.0
  /// or less.
  public var minimumRate: some ObservableReadOnlyProperty<PlaybackRate> {
    properties.MinimumRate
  }

  /// The maximum value which the `rate` property can take. Clients should
  /// not attempt to set the `rate` property above this value. This value
  /// should always be 1.0 or greater.
  public var maximumRate: some ObservableReadOnlyProperty<PlaybackRate> {
    properties.MaximumRate
  }

  /// Whether the client can call the `next` method on this interface and
  /// expect the current track to change. If it is unknown whether a call
  /// to `next` will be successful (for example, when streaming tracks),
  /// this property should be set to true. If `canControl` is false, this
  /// property should also be false.
  ///
  /// Rationale:
  /// Even when playback can generally be controlled, there may not
  /// always be a next track to move to.
  public var canGoNext: some ObservableReadOnlyProperty<Bool> {
    properties.CanGoNext
  }

  /// Whether the client can call the `previous` method on this interface
  /// and expect the current track to change. If it is unknown whether a
  /// call to `previous` will be successful (for example, when streaming
  /// tracks), this property should be set to true. If `canControl` is
  /// false, this property should also be false.
  ///
  /// Rationale:
  /// Even when playback can generally be controlled, there may not
  /// always be a previous track to move to.
  public var canGoPrevious: some ObservableReadOnlyProperty<Bool> {
    properties.CanGoPrevious
  }

  /// Whether playback can be started using `play` or `playPause`.
  /// Note that this is related to whether there is a "current track":
  /// the value should not depend on whether the track is currently
  /// paused or playing. In fact, if a track is currently playing (and
  /// `canControl` is true), this should be true. If `canControl` is
  /// false, this property should also be false.
  ///
  /// Rationale:
  /// Even when playback can generally be controlled, it may not be
  /// possible to enter a "playing" state, for example if there is no
  /// "current track".
  public var canPlay: some ObservableReadOnlyProperty<Bool> {
    properties.CanPlay
  }

  /// Whether playback can be paused using `pause` or `playPause`.
  /// Note that this is an intrinsic property of the current track: its
  /// value should not depend on whether the track is currently paused or
  /// playing. In fact, if playback is currently paused (and `canControl`
  /// is true), this should be true. If `canControl` is false, this
  /// property should also be false.
  ///
  /// Rationale:
  /// Not all media is pausable: it may not be possible to pause some
  /// streamed media, for example.
  public var canPause: some ObservableReadOnlyProperty<Bool> {
    properties.CanPause
  }

  /// Whether the client can control the playback position using `seek`
  /// and `setPosition`. This may be different for different tracks. If
  /// `canControl` is false, this property should also be false.
  ///
  /// Rationale:
  /// Not all media is seekable: it may not be possible to seek when
  /// playing some streamed media, for example.
  public var canSeek: some ObservableReadOnlyProperty<Bool> {
    properties.CanSeek
  }

  /// Whether the media player may be controlled over this interface.
  /// This property is not expected to change, as it describes an
  /// intrinsic capability of the implementation. If this is false,
  /// clients should assume that all properties on this interface are
  /// read-only (and will raise errors if writing to them is attempted),
  /// no methods are implemented and all other properties starting with
  /// "can" are also false.
  ///
  /// Rationale:
  /// This allows clients to determine whether to present and enable
  /// controls to the user in advance of attempting to call methods and
  /// write to properties.
  public var canControl: some ObservableReadOnlyProperty<Bool> {
    properties.CanControl
  }
}

/// Unique track identifier.
/// If the media player implements the `TrackList` interface and allows
/// the same track to appear multiple times in the tracklist, this must
/// be unique within the scope of the tracklist. Note that this should
/// be a valid D-Bus object id, although clients should not assume that
/// any object is actually exported with any interfaces at that path.
/// Media players may not use any paths starting with `/org/mpris` unless
/// explicitly allowed by this specification. Such paths are intended to
/// have special meaning, such as `/org/mpris/MediaPlayer2/TrackList/NoTrack`
/// to indicate "no track".
///
/// Rationale:
/// This is a D-Bus object id as that is the definitive way to have unique
/// identifiers on D-Bus. It also allows for future optional expansions to
/// the specification where tracks are exported to D-Bus with an interface
/// similar to `org.gnome.UPnP.MediaItem2`.
public typealias TrackId = ObjectPath

/// Time in microseconds.
public typealias Microseconds = Int64

/// A playback rate.
/// This is a multiplier, so a value of 0.5 indicates that playback is
/// happening at half speed, while 1.5 means that 1.5 seconds of "track
/// time" is consumed every second.
public typealias PlaybackRate = Double

/// Audio volume level.
/// 0.0 means mute.
/// 1.0 is a sensible maximum volume level (ex: 0dB).
/// Note that the volume may be higher than 1.0, although generally
/// clients should not attempt to set it above 1.0.
public typealias Volume = Double

/// A playback status.
public enum PlaybackStatus: String {
  /// A track is currently playing.
  case playing = "Playing"
  /// A track is currently paused.
  case paused = "Paused"
  /// There is no track currently playing.
  case stopped = "Stopped"
}

/// A playback state.
extension PlaybackStatus: Argument {
  public static var type: ArgumentType { .string }

  public init(from iter: inout MessageIterator) throws(DBus.Error) {
    self.init(rawValue: try String(from: &iter))!
  }

  public func append(to iter: inout MessageIterator) throws(Error) {
    try rawValue.append(to: &iter)
  }
}

/// A repeat / loop status.
public enum LoopStatus: String {
  /// The playback will stop when there are no more tracks to play.
  case none = "None"
  /// The current track will start again from the beginning once it has
  /// finished playing.
  case track = "Track"
  /// The playback loops through a list of tracks.
  case playlist = "Playlist"
}

extension LoopStatus: Argument {
  public static var type: ArgumentType { .string }

  public init(from iter: inout MessageIterator) throws(DBus.Error) {
    self.init(rawValue: try String(from: &iter))!
  }

  public func append(to iter: inout MessageIterator) throws(Error) {
    try rawValue.append(to: &iter)
  }
}
