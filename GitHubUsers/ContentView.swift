//
//  ContentView.swift
//  GitHubUsers
//
//  Created by Keyur Bhalodiya on 2024/06/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var appCoordinator = AppCoordinator(path: NavigationPath())
    @State private var isLoading: Bool = false

    var body: some View {
      NavigationStack(path: $appCoordinator.path) {
        appCoordinator.build()
          .navigationDestination(for: UserDetailsCoordinator.self) { coordinator in
              coordinator.build()
          }
      }
      .environmentObject(appCoordinator)
      .environment(\.isLoading, $isLoading)
      .hudOverlay(isLoading)
    }
}

struct LoadingEnvironmentKey: EnvironmentKey {
    public static let defaultValue: Binding<Bool> = .constant(false)
}

extension EnvironmentValues {
    var isLoading: Binding<Bool> {
        get {
            self [LoadingEnvironmentKey.self]
        }
        set {
            self [LoadingEnvironmentKey.self] = newValue
        }
    }
}

#Preview {
    ContentView()
}
