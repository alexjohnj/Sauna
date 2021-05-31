//
// Created by Alex Jackson on 31/05/2021.
//

import Foundation
import SwiftUI
import ComposableArchitecture

struct SetupWindowView: View {

    let store: Store<SetupWindowState, SetupWindowAction>
    @ObservedObject private var viewStore: ViewStore<SetupWindowState, SetupWindowAction>

    init(store: Store<SetupWindowState, SetupWindowAction>) {
        self.store = store
        viewStore = ViewStore(store)
    }

    var body: some View {
        VStack {
            Text("Enter the following information to configure Sauna:")

            VStack {
                HStack {
                    Text("Steam ID:")
                    TextField("Steam ID", text: viewStore.binding(get: \.steamID, send: SetupWindowAction.steamIDChanged))
                }

                HStack {
                    Text("Steam Web API Key:")
                    TextField("API Key", text: viewStore.binding(get: \.apiKey, send: SetupWindowAction.apiKeyChanged))
                }
            }

            HStack {
                Button("Quit") { print("I should quit now") }

                Spacer()

                Button("Done", action: { viewStore.send(.doneButtonClicked) })
                  .disabled(!viewStore.isDoneButtonEnabled)
            }
        }
          .padding()
    }
}
