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
  func loadGitHubUsers()
}

final class GitUsersViewModel: GitUsersViewState {
  
  // MARK: Dependencies
  private let dataProvider: GitUsersDataProviding
  private var cancellables = Set<AnyCancellable>()
  @Published var gitUsers: [User] = []

  init(dataProvider: GitUsersDataProviding) {
    self.dataProvider = dataProvider
    subscribeForGitHubUsers()
    loadGitHubUsers()
  }
  
  private func subscribeForGitHubUsers() {
    dataProvider.usersPublisher
      .receive(on: DispatchQueue.main)
      .sink { [weak self] users in
        self?.gitUsers = users
      }
      .store(in: &cancellables)
  }
  
  private func loadGitHubUsers() {
    self.dataProvider.loadGitHubUsers()
  }
}
