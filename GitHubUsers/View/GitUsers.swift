//
//  GitUsers.swift
//  GitHubUsers
//
//  Created by Keyur Bhalodiya on 2024/06/23.
//

import SwiftUI
import SDWebImageSwiftUI

protocol GitUsersViewState: ObservableObject {
  var gitUsers: [User] { get set }
  var lastUserId: Int? { get }
}

protocol GitUsersViewListner {
  func loadGitHubUsers()
}

typealias UsersListViewModel = GitUsersViewState & GitUsersViewListner

struct GitUsers<ViewModel: UsersListViewModel>: View {
  
  @StateObject private var viewModel: ViewModel
  
  public init(viewModel: ViewModel) {
    self._viewModel = StateObject(wrappedValue: viewModel)
  }
  
  var body: some View {
    NavigationView {
      rowContent
      .listStyle(.plain)
      .navigationTitle("GitHub Users")
    }
  }
  
  @ViewBuilder
  var rowContent: some View {
    List(viewModel.gitUsers, id: \.self) { user in
      HStack {
        WebImage(url: URL(string: user.avatarURL ?? ""))
               .resizable()
               .frame(width: 75, height: 75)
               .clipShape(.circle)
        Text(user.login ?? "")
          .font(.system(size: 22))
      }
      .onAppear {
        guard user.id == viewModel.lastUserId else { return }
        viewModel.loadGitHubUsers()
      }
    }
  }
}

// MARK: Preview

#if DEBUG
private final class GitUsersViewModelMock: UsersListViewModel {
  var lastUserId: Int?
  var gitUsers: [User] = [
    User(login: "User 1", id: 1, avatarURL: "https://placehold.co/75x75/png"),
    User(login: "User 2", id: 2, avatarURL: "https://placehold.co/75x75/png")
  ]
  func loadGitHubUsers() { }
}
#Preview {
  GitUsers(viewModel: GitUsersViewModelMock())
}

#endif
