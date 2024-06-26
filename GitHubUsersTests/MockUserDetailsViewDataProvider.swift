//
//  MockUserListViewDataProvider.swift
//  GitHubUsersTests
//
//  Created by Keyur Bhalodiya on 2024/06/26.
//

import Foundation
import Combine

@testable import GitHubUsers

final class MockUserDetailsViewDataProvider: UserDetailsViewDataProviding {
  
  @Published private var gitUserInfo: UserInfo?
  @Published private var gitRepos: [UserRepositories] = []

  var userInfo: AnyPublisher<GitHubUsers.UserInfo?, Never> {
    $gitUserInfo.eraseToAnyPublisher()
  }
  
  var repos: AnyPublisher<[GitHubUsers.UserRepositories], Never> {
    $gitRepos.eraseToAnyPublisher()
  }
  
  var hasLoadedAllRepos: Bool = false
  
  var responseToReturnUserInfo: UserInfo?
  var responseToReturnRepos: [UserRepositories]?
  var errorToReturn: NetworkError?
  
  func fetchUserInfo(forUser userName: String) {
     gitUserInfo = responseToReturnUserInfo
  }
  
  func loadGitRepos(forUser userName: String, fromPage pageIndex: Int) {
    guard let responseToReturnRepos else { return }
    gitRepos = responseToReturnRepos
  }
}
