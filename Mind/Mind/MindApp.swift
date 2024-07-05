//
//  Project_MindApp.swift
//  Project-Mind
//
//  Created by Nurdogan Karaman on 3.07.2024.
//

import SwiftUI
import SwiftData

/*
struct Project_MindApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
*/

@main
struct MindApp: App {
    var body: some Scene
    {
        WindowGroup
        {
            let _ = UserDefaults.standard.set(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")
            let _ = print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.path)
            ContentView()
                .onAppear
                {
                    if let window = NSApplication.shared.windows.first
                    {
                        if let screenSize = NSScreen.main?.frame.size
                        {
                            let halfScreenSize = NSSize(width: screenSize.width / 2, height: screenSize.height / 2)
                            window.setContentSize(halfScreenSize)
                            window.setFrame(NSRect(x: 0, y: 0, width: halfScreenSize.width, height: halfScreenSize.height), display: true)
                            window.setFrameAutosaveName("MainWindow")
                            window.styleMask = [.titled, .resizable, .closable, .miniaturizable, .fullSizeContentView]
                            window.isReleasedWhenClosed = false
                            window.center()
                            window.makeKeyAndOrderFront(nil)
                        }
                    }
                }
        }
        .modelContainer(for: [NodeData.self])
    }
}
