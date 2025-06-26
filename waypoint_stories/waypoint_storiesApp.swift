//
//  waypoint_storiesApp.swift
//  waypoint_stories
//
//  Created by Victoria Kwan on 6/25/25.
//

import SwiftUI

@main
struct waypoint_storiesApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
