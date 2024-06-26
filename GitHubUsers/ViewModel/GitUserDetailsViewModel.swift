//
//  GitUserDetailsViewModel.swift
//  GitHubUsers
//
//  Created by Keyur Bhalodiya on 2024/06/23.
//

import Foundation
import Combine

protocol GitUserDetailsDataProviding {
  var userInfo: AnyPublisher<UserInfo?, Never> { get }
  var repos: AnyPublisher<[UserRepositories], Never> { get }
  func fetchUserInfo(forUser userName: String)
  func loadGitRepos(forUser userName: String, fromPage pageIndex: Int)
}

final class GitUserDetailsViewModel: UserDetailsViewModel {
  
  // MARK: Dependencies
  private let dataProvider: GitUserDetailsDataProviding
  private let loginUsername: String
  
  private var cancellables = Set<AnyCancellable>()
  private var isLoadingRepos: Bool = false
  private var page: Int = 0
  
  @Published var userInfo: UserInfo?
  @Published var repos: [UserRepositories] = []
  
  init(loginUsername: String, dataProvider: GitUserDetailsDataProviding) {
    self.loginUsername = loginUsername
    self.dataProvider = dataProvider
    subscribeForUserDetailsAndRepos()
    fetchUserInfo()
    loadGitRepos()
  }
  
  var lastRepoId: Int? { 
    guard !repos.isEmpty else { return nil }
    return repos.last?.id
  }
  
  private func fetchUserInfo() {
    dataProvider.fetchUserInfo(forUser: loginUsername)
  }
  
  private func subscribeForUserDetailsAndRepos() {
    dataProvider.userInfo
      .receive(on: DispatchQueue.main)
      .sink { [weak self] userInfo in
        self?.userInfo = userInfo
      }
      .store(in: &cancellables)
    
    dataProvider.repos
      .receive(on: DispatchQueue.main)
      .sink { [weak self] repos in
        guard let self else { return }
        self.repos.append(contentsOf: repos)
        self.isLoadingRepos = false
      }
      .store(in: &cancellables)
  }
    
  func loadGitRepos() {
    guard !isLoadingRepos else { return }
    self.isLoadingRepos = true
    self.page += 1
    dataProvider.loadGitRepos(forUser: loginUsername, fromPage: page)
  }
  
}
