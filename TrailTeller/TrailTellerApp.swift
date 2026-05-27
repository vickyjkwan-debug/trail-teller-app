//
//  TrailTellerApp.swift
//  TrailTeller
//
//  Created by Victoria Kwan on 6/25/25.
//

import SwiftUI

@main
struct TrailTellerApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
