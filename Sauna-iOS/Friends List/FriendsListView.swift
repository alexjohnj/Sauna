//
//  FriendsListView.swift
//  Sauna-iOS
//
//  Created by Alex Jackson on 04/08/2020.
//  Copyright © 2020 Alex Jackson. All rights reserved.
//

import Foundation
import SwiftUI
import ComposableArchitecture
import LibSauna

struct FriendsListView: View {

    let store: Store<FriendsListState, FriendsListAction>

    private let columns: [GridItem] = [
        GridItem(.adaptive(minimum: 70), spacing: 24, alignment: .top)
    ]

    var body: some View {
        WithViewStore(store) { (vs: ViewStore<FriendsListState, FriendsListAction>) in
            switch (vs.friendsList.data, vs.friendsList.state) {
            case let (data?, _):
                ScrollView {
                    LazyVGrid(columns: columns, alignment: .leading, spacing: 16) {
                        ForEach(data, id: \.group) { section in
                            Section(header: FriendsListGroupHeader(group: section.group)) {
                                ForEach(section.profiles) { profile in
                                    NavigationLink(destination: ProfileDetailsView(profile: profile)) {
                                        ProfileView(profile: profile)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .environment(\.friendsListGroup, section.group)
                        }
                    }
                    .padding()
                }

            case (nil, .notRequested),
                 (nil, .loading):
                ProgressView()

            case (nil, .idle(let errorMessage?)):
                FriendsListErrorView(errorMessage: errorMessage, retry: { vs.send(.reload) })

            case (nil, .idle(nil)):
                EmptyView()
            }
        }
    }
}
