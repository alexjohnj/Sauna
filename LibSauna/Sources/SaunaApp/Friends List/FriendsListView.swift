//
// Created by Alex Jackson on 30/05/2021.
//

import Foundation
import SwiftUI
import ComposableArchitecture

struct FriendsListView: View {

    private static let updateTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter
    }()

    private struct ViewState: Equatable {
        let title = "Steam Friends"
        let subtitle: String

        init(friendsListState: FriendsListState) {
            let onlineFriendCount = friendsListState.loadedProfiles.filter { $0.status.isTechnicallyOnline }.count
            subtitle = "\(onlineFriendCount) online"
        }
    }

    let store: Store<FriendsListState, FriendsListAction>

    @ObservedObject private var viewStore: ViewStore<FriendsListState, FriendsListAction>

    private var sections: [FriendsListSection] {
        viewStore.friendsList.data ?? []
    }

    private var viewState: ViewState {
        ViewState(friendsListState: viewStore.state)
    }

    private var refreshHelpText: String {
        if let lastRefreshDate = viewStore.lastRefreshDate {
            return "Updated \(Self.updateTimeFormatter.string(from: lastRefreshDate))"
        } else {
            return "Refresh"
        }
    }

    public init(store: Store<FriendsListState, FriendsListAction>) {
        self.store = store
        viewStore = ViewStore(store)
    }

    public var body: some View {
        List {
            ForEach(sections, id: \.group) { section in
                Section(header: Text(section.group.localizedDescription)) {
                    ForEach(section.profiles) { profile in
                        ProfileRowView(profile: profile)
                          .frame(minHeight: 48)

                        Divider()
                    }
                }
            }
        }
        .navigationTitle(viewState.title)
        .navigationSubtitle(viewState.subtitle)
        .toolbar {
            ToolbarItem {
                Button { viewStore.send(.reload) }
                    label: { Image(systemName: "arrow.clockwise") }
                    .help(refreshHelpText)
            }
        }
    }
}
