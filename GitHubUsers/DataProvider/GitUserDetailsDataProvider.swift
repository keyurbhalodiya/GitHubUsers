//
//  UserDetailsViewDataProvider.swift
//  GitHubUsers
//
//  Created by Keyur Bhalodiya on 2024/06/26.
//

import Foundation
import Combine

final class UserDetailsViewDataProvider: UserDetailsViewDataProviding {
  
  private enum Constant {
    static let keyPage = "page"
    static let keyPerPageLimit = "per_page"
    static let perPageLimit = 30
  }
  
  private var cancellables: Set<AnyCancellable> = Set()
  private var hasLoadedAllRepos: Bool = false
  
  @Published private var gitUserInfo: UserInfo?
  @Published private var gitRepos: [UserRepositories] = []
  
  var userInfo: AnyPublisher<UserInfo?, Never> {
    $gitUserInfo.eraseToAnyPublisher()
  }
  
  var repos: AnyPublisher<[UserRepositories], Never> {
    $gitRepos.eraseToAnyPublisher()
  }
  
  func fetchUserInfo(forUser userName: String) {
    NetworkService.shared.getData(endpoint: "users/\(userName)", parameters: [:], type: UserInfo.self)
      .sink { completion in
        switch completion {
        case .failure(let err):
          print("Error is \(err.localizedDescription)")
        case .finished:
          print("Load use details successfully")
        }
      } receiveValue: { [weak self] userInfo in
        self?.gitUserInfo = userInfo
      } .store(in: &cancellables)
  }
  
  func loadGitRepos(forUser userName: String, fromPage pageIndex: Int) {
    guard !hasLoadedAllRepos else { return }
    var parameters: [String : Any] = [Constant.keyPerPageLimit : Constant.perPageLimit]
    parameters[Constant.keyPage] = pageIndex

    NetworkService.shared.getData(endpoint: "users/\(userName)/repos", parameters: parameters, type: [UserRepositories].self)
      .sink { completion in
        switch completion {
        case .failure(let err):
          print("Error is \(err.localizedDescription)")
        case .finished:
          print("Load repos successfully")
        }
      } receiveValue: { [weak self] repos in
        self?.gitRepos = repos
        self?.hasLoadedAllRepos = repos.count < Constant.perPageLimit
      } .store(in: &cancellables)
  }
}
