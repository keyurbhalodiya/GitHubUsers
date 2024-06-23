//
//  GitUsersViewModel.swift
//  GitHubUsers
//
//  Created by Keyur Bhalodiya on 2024/06/23.
//

import Foundation

final class GitUsersViewModel: GitUsersViewState {
        
  @Published var gitUsers: [User] = []

}
