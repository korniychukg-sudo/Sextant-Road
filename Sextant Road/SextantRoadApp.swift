import SwiftUI

@main
struct SextantRoadApp: App {
    @StateObject private var store = SeaStore()
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(store)
                .preferredColorScheme(.light)
        }
        .onChange(of: scenePhase) { phase in
            if phase == .background || phase == .inactive {
                store.saveNow()
            }
        }
    }
}
