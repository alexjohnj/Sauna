//
// Created by Alex Jackson on 31/05/2021.
//

import Foundation
import SwiftUI
import ComposableArchitecture

#if os(macOS)
import Cocoa
#endif

struct SetupWindowView: View {

    private static let formLabelWidth = 140 as CGFloat
    private static let formTextFieldWidth = 300 as CGFloat

    let store: Store<SetupWindowState, SetupWindowAction>
    @ObservedObject private var viewStore: ViewStore<SetupWindowState, SetupWindowAction>

    init(store: Store<SetupWindowState, SetupWindowAction>) {
        self.store = store
        viewStore = ViewStore(store)
    }

    var body: some View {
        Form {
            Text("Enter the following information to configure Sauna:")

            HStack {
                Text("Steam ID:")
                  .frame(minWidth: Self.formLabelWidth, alignment: .trailing)

                TextField("Steam ID", text: viewStore.binding(get: \.steamID, send: SetupWindowAction.steamIDChanged))
                  .frame(minWidth: Self.formTextFieldWidth)
            }

            HStack {
                Text("Steam Web API Key:")
                  .frame(minWidth: Self.formLabelWidth, alignment: .trailing)

                TextField("API Key", text: viewStore.binding(get: \.apiKey, send: SetupWindowAction.apiKeyChanged))
                  .frame(minWidth: Self.formTextFieldWidth)
            }

            HStack {
                Button("Quit") { viewStore.send(.quit) }

                Spacer()

                Button("Done", action: { viewStore.send(.doneButtonClicked) })
                  .disabled(!viewStore.isDoneButtonEnabled)
            }
        }
          .padding()
        .onAppear {
            #if os(macOS)
            DispatchQueue.main.async {
                NSApplication.shared.keyWindow?.preventsApplicationTerminationWhenModal = false
            }
            #endif
        }
    }
}
