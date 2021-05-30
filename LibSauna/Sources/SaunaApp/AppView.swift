//
// Created by Alex Jackson on 30/05/2021.
//

import Foundation
import SwiftUI
import ComposableArchitecture

public struct AppView: View {

    let store: Store<AppState, AppAction>

    public init(store: Store<AppState, AppAction>) {
        self.store = store
    }

    public var body: some View {
        Text("This is the app!")
    }
}
