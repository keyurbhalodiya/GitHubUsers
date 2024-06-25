//
//  DataProvider.swift
//  GitHubUsers
//
//  Created by Keyur Bhalodiya on 2024/06/23.
//

import Foundation
import Combine

final class DataProvider: GitUsersDataProviding {
  
  private enum Constant {
    static let keySince = "since"
    static let keyPerPageLimit = "per_page"
    static let perPageLimit = 30
  }
  
  private var cancellables: Set<AnyCancellable> = Set()
  private var hasLoadedAllUsers: Bool = false
  
  @Published private var users: [User] = []
  
  var usersPublisher: AnyPublisher<[User], Never> {
    $users.eraseToAnyPublisher()
  }
  
  func loadGitHubUsers(index: Int?) {
    guard !hasLoadedAllUsers else { return }
    var parameters: [String : Any] = [Constant.keyPerPageLimit : Constant.perPageLimit]
    if let index {
      parameters[Constant.keySince] = index
    }
    NetworkService.shared.getData(endpoint: "users", parameters: parameters, type: [User].self)
      .sink { completion in
        switch completion {
        case .failure(let err):
          print("Error is \(err.localizedDescription)")
        case .finished:
          print("Finished successfully")
        }
      } receiveValue: { [weak self] users in
        self?.users.append(contentsOf: users)
        self?.hasLoadedAllUsers = users.count < Constant.perPageLimit
      } .store(in: &cancellables)
  }
}
