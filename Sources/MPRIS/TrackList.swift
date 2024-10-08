import DBus
import Foundation

extension MediaPlayer2 {
  /// Provides access to a short list of tracks which were recently played or
  /// will be played shortly. This is intended to provide context to the
  /// currently-playing track, rather than giving complete access to the media
  /// player's playlist.
  ///
  /// Example use cases are the list of tracks from the same album as the
  /// currently playing song or the Rhythmbox play queue.
  ///
  /// Each track in the tracklist has a unique identifier. The intention is that
  /// this uniquely identifies the track within the scope of the tracklist. In
  /// particular, if a media item (a particular music file, say) occurs twice in
  /// the track list, each occurrence should have a different identifier. If a
  /// track is removed from the middle of the playlist, it should not affect the
  /// track ids of any other tracks in the tracklist.
  ///
  /// As a result, the traditional track identifiers of URLs and position in the
  /// playlist cannot be used. Any scheme which satisfies the uniqueness
  /// requirements is valid, as clients should not make any assumptions about
  /// the value of the track id beyond the fact that it is a unique identifier.
  ///
  /// Note that the (memory and processing) burden of implementing the
  /// `TrackList` interface and maintaining unique track ids for the playlist
  /// can be mitigated by only exposing a subset of the playlist when it is very
  /// long (the 20 or so tracks around the currently playing track, for example).
  /// This is a recommended practice as the `TrackList` interface is not
  /// designed to enable browsing through a large list of tracks, but rather to
  /// provide clients with context about the currently playing track.
  public struct TrackList {
    let methods: MethodsProxy
    let properties: PropertiesProxy
    let signals: SignalsProxy
  }
}

extension MediaPlayer2.TrackList {
  /// Gets all the metadata available for a set of tracks.
  /// Each set of metadata must have a `mpris:trackid` entry at the very
  /// least, which contains a string that uniquely identifies this track
  /// within the scope of the tracklist.
  ///
  /// - Parameter trackIds: The list of track ids for which metadata is
  /// requested.
  /// - Returns: Metadata of the set of tracks given as input.
  public func getTracksMetadata(trackIds: [TrackId]) throws(DBus.Error) -> [Metadata] {
    try methods.GetTracksMetadata(trackIds)
  }

  /// Async version of `getTracksMetadata`.
  @available(macOS 10.15.0, *)
  public func getTracksMetadata(trackIds: [TrackId]) async throws(DBus.Error) -> [Metadata] {
    try await methods.GetTracksMetadata(trackIds)
  }

  /// Adds a URI in the `TrackList`.
  /// If the `canEditTracks` property is false, this has no effect.
  /// Note: Clients should not assume that the track has been added at
  /// the time when this method returns. They should wait for a
  /// `TrackAdded` (or `TrackListReplaced`) signal.
  ///
  /// - Parameters:
  ///   - uri: The URI of the item to add. Its URI scheme should be an
  ///   element of the `org.mpris.MediaPlayer2.SupportedUriSchemes`
  ///   property and the mime-type should match one of the elements of
  ///   the `org.mpris.MediaPlayer2.SupportedMimeTypes`.
  ///   - afterTrack: The identifier of the track after which the new
  ///   item should be inserted. The path
  ///   `/org/mpris/MediaPlayer2/TrackList/NoTrack` indicates that the
  ///   track should be inserted at the start of the track list.
  ///   - setAsCurrent: Whether the newly inserted track should be
  ///   considered as the current track. Setting this to true has the
  ///   same effect as calling `goTo` afterwards.
  public func addTrack(uri: Uri, afterTrack: TrackId, setAsCurrent: Bool) throws(DBus.Error) {
    try methods.AddTrack(uri, afterTrack, setAsCurrent) as Void
  }

  /// Async version of `addTrack`.
  @available(macOS 10.15.0, *)
  public func addTrack(uri: Uri, afterTrack: TrackId, setAsCurrent: Bool) async throws(DBus.Error) {
    try await methods.AddTrack(uri, afterTrack, setAsCurrent) as Void
  }

  /// Removes an item from the `TrackList`.
  /// If the track is not part of this tracklist, this has no effect.
  /// If the `canEditTracks` property is false, this has no effect.
  /// Note: Clients should not assume that the track has been removed at
  /// the time when this method returns. They should wait for a
  /// `TrackRemoved` (or `TrackListReplaced`) signal.
  ///
  /// - Parameter trackId: Identifier of the track to be removed.
  /// `/org/mpris/MediaPlayer2/TrackList/NoTrack` is not a valid value
  /// for this argument.
  public func removeTrack(trackId: TrackId) throws(DBus.Error) {
    try methods.RemoveTrack(trackId) as Void
  }

  /// Async version of `removeTrack`.
  @available(macOS 10.15.0, *)
  public func removeTrack(trackId: TrackId) async throws(DBus.Error) {
    try await methods.RemoveTrack(trackId) as Void
  }

  /// Skip to the specified `TrackId`.
  /// If the track is not part of this tracklist, this has no effect.
  /// If this object is not `/org/mpris/MediaPlayer2`, the current
  /// `TrackList`'s tracks should be replaced with the contents of this
  /// `TrackList`, and the `TrackListReplaced` signal should be fired
  /// from `/org/mpris/MediaPlayer2`.
  ///
  /// - Parameter trackId: Identifier of the track to skip to.
  /// `/org/mpris/MediaPlayer2/TrackList/NoTrack` is not a valid value
  /// for this argument.
  public func goTo(trackId: TrackId) throws(DBus.Error) {
    try methods.GoTo(trackId) as Void
  }

  /// Async version of `goTo`.
  @available(macOS 10.15.0, *)
  public func goTo(trackId: TrackId) async throws(DBus.Error) {
    try await methods.GoTo(trackId) as Void
  }

  /// Indicates that the entire tracklist has been replaced.
  /// It is left up to the implementation to decide when a change to the
  /// track list is invasive enough that this signal should be emitted
  /// instead of a series of `TrackAdded` and `TrackRemoved` signals.
  ///
  /// - Parameter handler: The signal handler.
  ///   - tracks: The new content of the tracklist.
  ///   - currentTrack: The identifier of the track to be considered as
  ///   current. `/org/mpris/MediaPlayer2/TrackList/NoTrack` indicates
  ///   that there is no current track. This should correspond to the
  ///   `mpris:trackid` field of the `metadata` property of the
  ///   `org.mpris.MediaPlayer2.Player` interface.
  /// - Returns: A function that disconnects the signal handler.
  public func trackListReplaced(
    _ handler: @escaping (_ tracks: [TrackId], _ currentTrack: TrackId) -> Void
  ) throws(DBus.Error) -> () throws(DBus.Error) -> Void {
    try signals.TrackListReplaced.connect(handler)
  }

  /// Indicates that a track has been added to the track list.
  ///
  /// - Parameter handler: The signal handler.
  ///   - metadata: The metadata of the newly added item. This must
  ///   include a `mpris:trackid` entry. See the type documentation for
  ///   more details.
  ///   - afterTrack: The identifier of the track after which the new
  ///   track was inserted. The path
  ///   `/org/mpris/MediaPlayer2/TrackList/NoTrack` indicates that the
  ///   track was inserted at the start of the track list.
  /// - Returns: A function that disconnects the signal handler.
  public func trackAdded(
    _ handler: @escaping (_ metadata: Metadata, _ afterTrack: TrackId) -> Void
  ) throws(DBus.Error) -> () throws(DBus.Error) -> Void {
    try signals.TrackAdded.connect(handler)
  }

  /// Indicates that a track has been removed from the track list.
  ///
  /// - Parameter handler: The signal handler.
  ///   - trackId: The identifier of the track being removed.
  /// `/org/mpris/MediaPlayer2/TrackList/NoTrack` is not a valid value
  /// for this argument.
  /// - Returns: A function that disconnects the signal handler.
  public func trackRemoved(
    _ handler: @escaping (_ trackId: TrackId) -> Void
  ) throws(DBus.Error) -> () throws(DBus.Error) -> Void {
    try signals.TrackRemoved.connect(handler)
  }

  /// Indicates that the metadata of a track in the tracklist has changed.
  /// This may indicate that a track has been replaced, in which case the
  /// `mpris:trackid` metadata entry is different from the `trackId`
  /// argument.
  ///
  /// - Parameter handler: The signal handler.
  ///   - trackId: The id of the track which metadata has changed. If the
  ///   track id has changed, this will be the old value.
  ///   `/org/mpris/MediaPlayer2/TrackList/NoTrack` is not a valid value
  ///   for this argument.
  ///   - metadata: The new track metadata. This must include a
  ///   `mpris:trackid` entry. If the track id has changed, this will be
  ///   the new value. See the type documentation for more details.
  /// - Returns: A function that disconnects the signal handler.
  public func trackMetadataChanged(
    _ handler: @escaping (_ trackId: TrackId, _ metadata: Metadata) -> Void
  ) throws(DBus.Error) -> () throws(DBus.Error) -> Void {
    try signals.TrackMetadataChanged.connect(handler)
  }

  /// An array which contains the identifier of each track in the
  /// tracklist, in order.
  /// The `org.freedesktop.DBus.Properties.PropertiesChanged` signal is
  /// emitted every time this property changes, but the signal message
  /// does not contain the new value. Client implementations should
  /// rather rely on the `TrackAdded`, `TrackRemoved` and
  /// `TrackListReplaced` signals to keep their representation of the
  /// tracklist up to date.
  public var tracks: some ObservableReadOnlyProperty<[TrackId]> {
    properties.Tracks
  }

  /// If false, calling `addTrack` or `removeTrack` will have no effect,
  /// and may raise a `NotSupported` error.
  public var canEditTracks: some ObservableReadOnlyProperty<Bool> {
    properties.CanEditTracks
  }
}

/// A URI.
public typealias Uri = String

/// Date/time fields should be sent as strings in ISO 8601 extended format.
/// If the timezone is known (eg: for `xesam:lastPlayed`), the internet
/// profile format of ISO 8601, as specified in [RFC 3339](http://www.apps.ietf.org/rfc/rfc3339.html#sec-5.6),
/// should be used.
public struct DateTime {
  /// The date/time.
  public let date: Date

  /// Initializes a new date/time.
  ///
  /// - Parameter date: The date/time.
  public init(date: Date) {
    self.date = date
  }

  /// Initializes a new date/time from a string.
  ///
  /// - Parameter string: The string representation of the date/time.
  public init?(string: String) {
    guard let date = ISO8601DateFormatter().date(from: string) else {
      return nil
    }
    self.date = date
  }

  /// The string representation of the date/time.
  public var string: String {
    ISO8601DateFormatter().string(from: date)
  }
}

extension DateTime: Argument {
  public static var type: ArgumentType { .string }

  public init(from iter: inout MessageIterator) throws(DBus.Error) {
    self.init(string: try String(from: &iter))!
  }

  public func append(to iter: inout MessageIterator) throws(Error) {
    try string.append(to: &iter)
  }
}

/// A mapping from metadata attribute names to values.
/// The `mpris:trackid` attribute must always be present, and must be of
/// D-Bus type "o". This contains a D-Bus path that uniquely identifies
/// the track within the scope of the playlist. There may or may not be
/// an actual D-Bus object at that path; this specification says nothing
/// about what interfaces such an object may implement.
/// If the length of the track is known, it should be provided in the
/// metadata property with the `mpris:length` key. The length must be
/// given in microseconds, and be represented as a signed 64-bit integer.
/// If there is an image associated with the track, a URL for it may be
/// provided using the `mpris:artUrl` key. For other metadata, fields
/// defined by the Xesam ontology should be used, prefixed by `xesam:`.
/// See the [metadata page on the freedesktop.org wiki](http://www.freedesktop.org/wiki/Specifications/mpris-spec/metadata)
/// for a list of common fields.
/// Lists of strings should be passed using the array-of-string ("as")
/// D-Bus type. Dates should be passed as strings using the ISO 8601
/// extended format (eg: 2007-04-29T14:35:51). If the timezone is known,
/// RFC 3339's internet profile should be used (eg: 2007-04-29T14:35:51+02:00).
public struct Metadata {
  var dict: [String: Variant<AnyArgument>]

  /// Initializes a new metadata.
  /// - Parameters:
  ///   - trackId: The unique identity for this track within the context
  ///   of an MPRIS object (eg: tracklist).
  public init(trackId: TrackId) {
    self.dict = [:]
    self.trackId = trackId
  }
}

extension Metadata {
  /// Gets or sets the metadata value for the specified key.
  public subscript(key: String) -> (any Argument)? {
    get { dict[key]?.value.value }
    set { dict[key] = newValue.map(AnyArgument.init).map(Variant.init) }
  }
}

extension Metadata {
  /// A unique identity for this track within the context of an MPRIS
  /// object (eg: tracklist).
  public var trackId: TrackId {
    get { self["mpris:trackid"] as! TrackId }
    set { self["mpris:trackid"] = newValue }
  }

  /// The duration of the track in microseconds.
  public var length: Microseconds? {
    get { self["mpris:length"] as? Microseconds }
    set { self["mpris:length"] = newValue }
  }

  /// The location of an image representing the track or album.
  /// Clients should not assume this will continue to exist when the
  /// media player stops giving out the URL.
  public var artUrl: Uri? {
    get { self["mpris:artUrl"] as? Uri }
    set { self["mpris:artUrl"] = newValue }
  }

  /// The album name.
  public var album: String? {
    get { self["xesam:album"] as? String }
    set { self["xesam:album"] = newValue }
  }

  /// The album artist(s).
  public var albumArtist: [String]? {
    get { (self["xesam:albumArtist"] as? [AnyArgument])?.compactMap { $0.value as? String } }
    set { self["xesam:albumArtist"] = newValue }
  }

  /// The track artist(s).
  public var artist: [String]? {
    get { (self["xesam:artist"] as? [AnyArgument])?.compactMap { $0.value as? String } }
    set { self["xesam:artist"] = newValue }
  }

  /// The track lyrics.
  public var asText: String? {
    get { self["xesam:asText"] as? String }
    set { self["xesam:asText"] = newValue }
  }

  /// The speed of the music, in beats per minute.
  public var audioBPM: Int32? {
    get { self["xesam:audioBPM"] as? Int32 }
    set { self["xesam:audioBPM"] = newValue }
  }

  /// An automatically-generated rating, based on things such as how
  /// often it has been played. This should be in the range 0.0 to 1.0.
  public var autoRating: Double? {
    get { self["xesam:autoRating"] as? Double }
    set { self["xesam:autoRating"] = newValue }
  }

  /// A (list of) freeform comment(s).
  public var comment: [String]? {
    get { (self["xesam:comment"] as? [AnyArgument])?.compactMap { $0.value as? String } }
    set { self["xesam:comment"] = newValue }
  }

  /// The composer(s) of the track.
  public var composer: [String]? {
    get { (self["xesam:composer"] as? [AnyArgument])?.compactMap { $0.value as? String } }
    set { self["xesam:composer"] = newValue }
  }

  /// When the track was created. Usually only the year component will
  /// be useful.
  public var contentCreated: DateTime? {
    get { (self["xesam:contentCreated"] as? String).flatMap(DateTime.init) }
    set { self["xesam:contentCreated"] = newValue?.string }
  }

  /// The disc number on the album that this track is from.
  public var discNumber: Int32? {
    get { self["xesam:discNumber"] as? Int32 }
    set { self["xesam:discNumber"] = newValue }
  }

  /// When the track was first played.
  public var firstUsed: DateTime? {
    get { (self["xesam:firstUsed"] as? String).flatMap(DateTime.init) }
    set { self["xesam:firstUsed"] = newValue?.string }
  }

  /// The genre(s) of the track.
  public var genre: [String]? {
    get { (self["xesam:genre"] as? [AnyArgument])?.compactMap { $0.value as? String } }
    set { self["xesam:genre"] = newValue }
  }

  /// When the track was last played.
  public var lastUsed: DateTime? {
    get { (self["xesam:lastUsed"] as? String).flatMap(DateTime.init) }
    set { self["xesam:lastUsed"] = newValue?.string }
  }

  /// The lyricist(s) of the track.
  public var lyricist: [String]? {
    get { (self["xesam:lyricist"] as? [AnyArgument])?.compactMap { $0.value as? String } }
    set { self["xesam:lyricist"] = newValue }
  }

  /// The track title.
  public var title: String? {
    get { self["xesam:title"] as? String }
    set { self["xesam:title"] = newValue }
  }

  /// The track number on the album disc.
  public var trackNumber: Int32? {
    get { self["xesam:trackNumber"] as? Int32 }
    set { self["xesam:trackNumber"] = newValue }
  }

  /// The location of the media file.
  public var url: Uri? {
    get { self["xesam:url"] as? Uri }
    set { self["xesam:url"] = newValue }
  }

  /// The number of times the track has been played.
  public var useCount: Int32? {
    get { self["xesam:useCount"] as? Int32 }
    set { self["xesam:useCount"] = newValue }
  }

  /// A user-specified rating. This should be in the range 0.0 to 1.0.
  public var userRating: Double? {
    get { self["xesam:userRating"] as? Double }
    set { self["xesam:userRating"] = newValue }
  }
}

extension Metadata: Argument {
  public static var type: ArgumentType { .array }

  public static var signature: Signature { [String: Variant<AnyArgument>].signature }

  public var signature: Signature { dict.signature }

  public init(from iter: inout MessageIterator) throws(DBus.Error) {
    dict = try [String: Variant<AnyArgument>](from: &iter)
  }

  public func append(to iter: inout MessageIterator) throws(Error) {
    try dict.append(to: &iter)
  }
}
