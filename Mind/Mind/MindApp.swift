//
//  Project_MindApp.swift
//  Project-Mind
//
//  Created by Nurdogan Karaman on 3.07.2024.
//

import SwiftUI
import SwiftData

@main
struct MindApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    if let window = NSApplication.shared.windows.first {
                        if let screenSize = NSScreen.main?.frame.size {
                            let halfScreenSize = NSSize(width: screenSize.width / 2, height: screenSize.height / 2)
                            window.setContentSize(halfScreenSize)
                            window.setFrame(NSRect(x: 0, y: 0, width: halfScreenSize.width, height: halfScreenSize.height), display: true)
                            window.setFrameAutosaveName("MainWindow")
                            window.styleMask = [.titled, .resizable, .closable, .miniaturizable, .fullSizeContentView]
                            window.isReleasedWhenClosed = false
                            window.center()
                            
                            #if DEBUG
                            window.title += " (Dev)"
                            #endif
                            
                            window.makeKeyAndOrderFront(nil)
                        }
                    }
                }
                .modelContainer(try! setupModelContainer())
        }
    }
    
    func setupModelContainer() throws -> ModelContainer {
        let containerURL = FileHelper.getSavingDirectory().appendingPathComponent("user")
        let configuration = ModelConfiguration(url: containerURL)
        let container = try ModelContainer(for: BoardData.self, NodeData.self, configurations: configuration)
        return container
    }
}
