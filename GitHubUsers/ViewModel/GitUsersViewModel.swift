//
//  GitUsersViewModel.swift
//  GitHubUsers
//
//  Created by Keyur Bhalodiya on 2024/06/23.
//

import Foundation
import Combine

protocol GitUsersDataProviding {
  var usersPublisher: AnyPublisher<[User], Never> { get }
  func loadGitHubUsers(index: Int?)
}

final class GitUsersViewModel: UsersListViewModel {
  
  // MARK: Dependencies
  private let dataProvider: GitUsersDataProviding
  
  private var cancellables = Set<AnyCancellable>()
  private var isLoading: Bool = false
  @Published var gitUsers: [User] = []

  var lastUserId: Int? {
    guard !gitUsers.isEmpty else { return nil }
    return gitUsers.last?.id
  }
  
  init(dataProvider: GitUsersDataProviding) {
    self.dataProvider = dataProvider
    subscribeForGitHubUsers()
    loadGitHubUsers()
  }
  
  private func subscribeForGitHubUsers() {
    dataProvider.usersPublisher
      .receive(on: DispatchQueue.main)
      .sink { [weak self] users in
        guard let self else { return }
        self.gitUsers.append(contentsOf: users)
        self.isLoading = false
      }
      .store(in: &cancellables)
  }
  
  func loadGitHubUsers() {
    guard !isLoading else { return }
    self.isLoading = true
    self.dataProvider.loadGitHubUsers(index: lastUserId)
  }
}

