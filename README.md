# Sauna

Sauna is a macOS (and watchOS, see below) app that lets you check which of your
Steam friends are online without running the full Steam client.

![Screenshot of Sauna for macOS.](/Screenshots/macOS.png?raw=true)

Compared to the Steam client, Sauna is lightweight and a good macOS
citizen. Sauna is useful for people who play games in Boot Camp and want to see
who's online without rebooting or running the Steam client.

Sauna will notify you when a friend comes online or starts playing a new
game. These notifications can, of course, be disabled if you don't want them.

## watchOS App

There is also a companion watchOS app in this repository. It offers similar
functionality to the macOS app but is missing a few features, notably:

- No auto-refreshing of the friends list.
- No notifications for friends coming online and launching games.

![Screenshot of Sauna for watchOS.](/Screenshots/watchOS.png?raw=true)

## Requirements & Set Up

### macOS

Sauna requires macOS 10.15 (Catalina) or newer.

To configure Sauna, you'll need a [Steam Web API key][api-docs] and your 64-bit
Steam ID. You can get a personal API key by filling in [a form][api-key-form] on
Steam's website. For many users, your Steam ID is the number in your profile's
Steam community URL. If you have a vanity URL, there are various [online
tools][steamid-io] that will retrieve your Steam ID.

[api-docs]: https://steamcommunity.com/dev
[api-key-form]: https://steamcommunity.com/dev/apikey
[steamid-io]: https://steamid.io

### watchOS

Sauna for watchOS requires watchOS 7 or newer.

Configuring the watchOS app is a bit more complex than the macOS app as you have
to build you're own copy of it. Before starting, you'll need to have an Apple
developer account and have registered your Apple Watch on the developer portal.

To build the watchOS app, create a file in the root of the project directory
called `Secrets.swift`. In it, add the following

``` swift
import LibSauna

let kMySteamID = SteamID(rawValue: "YOUR_STEAM_ID")!
let kMySteamAPIKey: APIKey = "YOUR_STEAM_API_KEY"
```

filling in your [Steam Web API key][api-docs] and your 64-bit [Steam
ID][steamid-io].

Once you've created this file, open the project in Xcode and navigate to the
project settings screen. For the _"SaunaWatch"_, _"SaunaWatch WatchKit App"_ and
_"SaunaWatch WatchKit Extension"_ targets, change the team to your developer
account's team. You'll possibly also need to change the bundle IDs of the
targets.

Now you can run the app on your watch by running the _"SaunaWatch WatchKit App"_
scheme in Xcode. This may take a few tries as Xcode is unreliable when it comes
to running apps on a device.

## Development

Sauna for macOS is built using AppKit while the watchOS app is built using
SwiftUI. Both apps use [The Composable Architecture][tca-github] and share much
of their code via. the `LibSauna` package.

I had intended to port Sauna for macOS to SwiftUI but given the state of SwiftUI
on macOS Big Sur, this is not going to happen with this release.

[tca-github]: https://github.com/pointfreeco/swift-composable-architecture

## Known Limitations

Sauna is limited to displaying 100 friends out of laziness. If this turns out to
be a significant issue, I'll look into increasing it.
