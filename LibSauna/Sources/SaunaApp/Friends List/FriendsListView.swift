//
// Created by Alex Jackson on 30/05/2021.
//

import Foundation
import SwiftUI
import ComposableArchitecture

struct FriendsListView: View {

    let store: Store<FriendsListState, FriendsListAction>

    @ObservedObject private var viewStore: ViewStore<FriendsListState, FriendsListAction>

    private var sections: [FriendsListSection] {
        viewStore.friendsList.data ?? []
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
                        Text(profile.name)
                    }
                }
            }
        }
          .onAppear { viewStore.send(.reload) }
    }
}
