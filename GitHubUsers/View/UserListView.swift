//
//  UserListView.swift
//  GitHubUsers
//
//  Created by Keyur Bhalodiya on 2024/06/23.
//

import SwiftUI
import Combine
import SDWebImageSwiftUI

protocol UserListViewState: ObservableObject {
  var users: [User] { get }
  var lastUserId: Int? { get }
  var isLoading: Bool { get }
}

protocol UserListViewListner {
  func loadGitHubUsers()
  func searchUsers(with name: String)
  func dismissSearchUsers()
}

typealias UsersListViewModel = UserListViewState & UserListViewListner

struct UserListView<ViewModel: UsersListViewModel>: View {
  
  @StateObject private var viewModel: ViewModel
  @State private var searchText = ""

  let didClickUser = PassthroughSubject<User, Never>()

  public init(viewModel: ViewModel) {
    self._viewModel = StateObject(wrappedValue: viewModel)
  }
  
  var body: some View {
    rowContent
    .listStyle(.plain)
    .navigationTitle("GitHub Users")
    .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
    .onChange(of: searchText) { newValue in
      guard newValue.count > 0 else {
        viewModel.dismissSearchUsers()
        return
      }
      viewModel.searchUsers(with: newValue)
    }
    .hudOverlay(viewModel.isLoading)
  }
  
  
  @ViewBuilder
  var rowContent: some View {
    List(viewModel.users, id: \.self) { user in
      HStack {
        WebImage(url: URL(string: user.avatarURL ?? ""))
               .resizable()
               .frame(width: 75, height: 75)
               .clipShape(.circle)
        Text(user.login ?? "")
          .font(.system(size: 22))
        Spacer()
      }
      .contentShape(Rectangle())
      .onAppear {
        guard user.id == viewModel.lastUserId else { return }
        viewModel.loadGitHubUsers()
      }
      .onTapGesture {
        didClickUser.send(user)
      }
    }
  }
}

// MARK: Preview

#if DEBUG
private final class UserListViewModelMock: UsersListViewModel {
  var isLoading: Bool = true
  var lastUserId: Int?
  var users: [User] = [
    User(login: "User 1", id: 1, avatarURL: "https://placehold.co/75x75/png"),
    User(login: "User 2", id: 2, avatarURL: "https://placehold.co/75x75/png")
  ]
  func loadGitHubUsers() { }
  func searchUsers(with name: String) { }
  func dismissSearchUsers() { }
}
#Preview {
  UserListView(viewModel: UserListViewModelMock())
}

#endif
