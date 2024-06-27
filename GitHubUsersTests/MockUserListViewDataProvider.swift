//
//  MockUserDetailsViewDataProvider.swift
//  GitHubUsersTests
//
//  Created by Keyur Bhalodiya on 2024/06/26.
//

import Foundation
import Combine

@testable import GitHubUsers

final class MockUserListViewDataProvider: UserListViewDataProviding {
  
  @Published private var users: [User] = []
  @Published private var usersSearch: [User] = []

  var usersPublisher: AnyPublisher<[GitHubUsers.User], Never> {
    $users.eraseToAnyPublisher()
  }
  
  var usersSearchPublisher: AnyPublisher<[GitHubUsers.User], Never> {
    $usersSearch.eraseToAnyPublisher()
  }

  var responseToReturn: [User]?
  var errorToReturn: NetworkError?
  var responseToReturnSearch: UsersSearch?
  
  var hasLoadedAllUsers: Bool = false
  
  func loadGitHubUsers(index: Int?) {
    guard let responseToReturn else { return }
    users = responseToReturn
  }
  
  func searchUsers(with name: String) {
    usersSearch = responseToReturnSearch?.users ?? []
  }
}
