# Sauna

Sauna is a macOS app that lets you check which of your Steam friends are online
without running the full Steam client.

![Sauna Screenshot](/screenshot.png?raw=true)

Compared to the Steam client, Sauna is lightweight and a good macOS
citizen. Sauna is useful for people who play games in Boot Camp and want to see
who's online without rebooting or running the Steam client.

Sauna will notify you when a friend comes online or starts playing a new
game. These notifications can, of course, be disabled if you don't want them.

## Requirements & Set Up

Sauna requires macOS 10.15 (Catalina) or newer.

To configure Sauna, you'll need a [Steam Web API key][api-docs] and your 64-bit
Steam ID. You can get a personal API key by filling in [a form][api-key-form] on
Steam's website. For many users, your Steam ID is the number in your profile's
Steam community URL. If you have a vanity URL, there are various [online
tools][steamid-io] that will retrieve your Steam ID.

[api-docs]: https://steamcommunity.com/dev
[api-key-form]: https://steamcommunity.com/dev/apikey
[steamid-io]: https://steamid.io

## Development

Sauna is built using AppKit and the [Composable Architecture][tca-github]. I
intend to port Sauna to SwiftUI when I feel it's ready but at the time Sauna was
developed (June 2020), SwiftUI on the Mac still had too many bugs.

[tca-github]: https://github.com/pointfreeco/swift-composable-architecture

## Known Limitations

Sauna is limited to displaying 100 friends out of laziness. If this turns out to
be a significant issue, I'll look into increasing it.
