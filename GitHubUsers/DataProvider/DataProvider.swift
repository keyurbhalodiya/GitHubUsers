//
//  DataProvider.swift
//  GitHubUsers
//
//  Created by Keyur Bhalodiya on 2024/06/23.
//

import Foundation
import Combine

final class DataProvider: GitUsersDataProviding {
  
  private var cancellables: Set<AnyCancellable> = Set()
  
  @Published private var users: [User] = []
  
  var usersPublisher: AnyPublisher<[User], Never> {
    $users.eraseToAnyPublisher()
  }
  
  func loadGitHubUsers() {
    NetworkService.shared.getData(endpoint: "users", type: [User].self)
      .sink { completion in
        switch completion {
        case .failure(let err):
          print("Error is \(err.localizedDescription)")
        case .finished:
          print("Finished")
        }
      } receiveValue: { [weak self] users in
        self?.users.append(contentsOf: users)
      } .store(in: &cancellables)
  }
  
}
