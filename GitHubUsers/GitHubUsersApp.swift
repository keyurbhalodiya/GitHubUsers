//
//  GitHubUsersApp.swift
//  GitHubUsers
//
//  Created by Keyur Bhalodiya on 2024/06/23.
//

import SwiftUI

@main
struct GitHubUsersApp: App {
    var body: some Scene {
        WindowGroup {
          GitUsers(viewModel: GitUsersViewModel(dataProvider: DataProvider()))
        }
    }
}
