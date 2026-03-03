//
//  musicPlayerApp.swift
//  musicPlayer
//
//  Created by wearrier on 2026/02/20.
//

import SwiftUI

@main
struct musicPlayerApp: App {
    var body: some Scene {
        WindowGroup {
            Player().onDisappear()
            {
                Player.terminateApp()
            }
        }
    }
}
