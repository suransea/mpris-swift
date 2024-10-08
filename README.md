# mpris-swift

![Github Release](https://flat.badgen.net/github/release/suransea/mpris-swift)
[![GitHub Actions Workflow Status](https://img.shields.io/github/actions/workflow/status/suransea/mpris-swift/swift.yml?style=flat-square)](https://github.com/suransea/mpris-swift/actions)
![GitHub License](https://img.shields.io/github/license/suransea/mpris-swift?style=flat-square)
[![Swift Version Compatibility](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fsuransea%2Fmpris-swift%2Fbadge%3Ftype%3Dswift-versions&style=flat-square)](https://swiftpackageindex.com/suransea/mpris-swift)
[![Platform Compatibility](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fsuransea%2Fmpris-swift%2Fbadge%3Ftype%3Dplatforms&style=flat-square)](https://swiftpackageindex.com/suransea/mpris-swift)

A library for interacting with [MPRIS](https://specifications.freedesktop.org/mpris-spec/latest/) players.

## Documentation

The [API Documentation](https://swiftpackageindex.com/suransea/mpris-swift/main/documentation/mpris) is available on Swift Package Index.

## Example

```swift
let connection = try Connection(type: .session)
try connection.setupDispatch(with: DispatchQueue.main)
let sessionManager = try MediaPlayer2.SessionManager(connection: connection)
if let player = sessionManager.activePlayer {
  try await player.player.pause()
  print(try await player.player.playbackStatus.get())
}
```

## License

[MIT license](LICENSE)
