//
//  ContentView.swift
//  GitHubUsers
//
//  Created by Keyur Bhalodiya on 2024/06/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var appCoordinator = AppCoordinator(path: NavigationPath())
    
    var body: some View {
      NavigationStack(path: $appCoordinator.path) {
        appCoordinator.build()
          .navigationDestination(for: UserDetailsCoordinator.self) { coordinator in
              coordinator.build()
          }
      }
      .environmentObject(appCoordinator)
    }
}

#Preview {
    ContentView()
}
