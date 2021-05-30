//
// Created by Alex Jackson on 30/05/2021.
//

import Foundation
import SwiftUI
import SaunaKit

struct ProfileRowView: View {

    private struct StatusView: View {

        var status: Profile.Status
        @Environment(\.accessibilityDifferentiateWithoutColor) private var shouldDifferentiateWithoutColor: Bool

        private var image: NSImage {
            switch status {
            case .online,
                 .lookingToPlay,
                 .lookingToTrade:
                return shouldDifferentiateWithoutColor ?
                    NSImage(named: "NSStatusAvailableFlat") ?? NSImage(named: NSImage.statusAvailableName)! :
                    NSImage(named: NSImage.statusAvailableName)!

            case .snooze,
                 .busy,
                 .away:
                return shouldDifferentiateWithoutColor ?
                    NSImage(named: "NSStatusPartiallyAvailableFlat") ?? NSImage(named: NSImage.statusPartiallyAvailableName)! :
                    NSImage(named: NSImage.statusPartiallyAvailableName)!

            case .offline:
                return shouldDifferentiateWithoutColor ?
                    NSImage(named: "NSStatusUnavailableFlat") ?? NSImage(named: NSImage.statusUnavailableName)! :
                    NSImage(named: NSImage.statusUnavailableName)!
            }
        }

        var body: some View {
            Image(nsImage: image)
        }
    }

    let profile: Profile

    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            StatusView(status: profile.status)

            VStack(alignment: .leading, spacing: 0) {
                Text(profile.name)

                if let statusDescription = profile.statusDescription {
                    Text(statusDescription)
                        .font(.subheadline)
                        .foregroundColor(Color.secondary)
                }
            }
        }
    }

}

#if DEBUG
struct ProfileRowViewPreviews: PreviewProvider {

    static var previews: some View {
        Group {
            ProfileRowView(profile: .fixture())
                .previewDisplayName("Online friend")

            ProfileRowView(profile: .fixture(currentGame: "Borderlands"))
                .previewDisplayName("Online friend with game status")

            ProfileRowView(profile: .fixture(status: .offline))
                .previewDisplayName("Offline friend")
        }
        .frame(minWidth: 320, alignment: .leading)
        .padding()
    }

}
#endif
