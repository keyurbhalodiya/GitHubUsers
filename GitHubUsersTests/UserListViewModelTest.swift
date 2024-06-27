//
//  UserListViewModelTest.swift
//  GitHubUsersTests
//
//  Created by Keyur Bhalodiya on 2024/06/26.
//

import Foundation
import Quick
import Nimble

@testable import GitHubUsers

final class UserListViewModelTest: AsyncSpec {
  override class func spec() {
    var viewModel: UserListViewModel!
    var mockDataProvider: MockUserListViewDataProvider!
    beforeEach {
      mockDataProvider = MockUserListViewDataProvider()
    }
    
    describe("loadGitHubUsers on first launch") {
      context("loadGitHubUsers success") {
        beforeEach {
          mockDataProvider.responseToReturn = Helper.loadLocalTestDataWithoutParsing("UserList", type: [User].self)
          viewModel = UserListViewModel(dataProvider: mockDataProvider)
          viewModel.loadGitHubUsers()
        }
        
        it("should return correct users count") {
          await expect(viewModel.users.count).toEventually(equal(5))
        }
      }
      
      context("loadGitHubUsers failed") {
        beforeEach {
          mockDataProvider.responseToReturn = Helper.loadLocalTestDataWithoutParsing("APIError", type: [User].self)
          mockDataProvider.errorToReturn = .unknown
          viewModel = UserListViewModel(dataProvider: mockDataProvider)
          viewModel.loadGitHubUsers()
        }
        
        it("should return users count 0") {
          await expect(viewModel.users.count).toEventually(equal(0))
        }
      }
    }
    
    describe("loadGitHubUsers with pagination") {
      beforeEach {
        mockDataProvider.responseToReturn = Helper.loadLocalTestDataWithoutParsing("UserList", type: [User].self)
        viewModel = UserListViewModel(dataProvider: mockDataProvider)
        viewModel.loadGitHubUsers()
      }
      
      context("loadGitHubUsers success") {
        it("should return correct users count 10 eventually") {
          await expect(viewModel.users.count).toEventually(equal(5))
          
          viewModel.loadGitHubUsers()
          await expect(viewModel.users.count).toEventually(equal(10))
        }
      }
      
      context("loadGitHubUsers failed") {
        it("should return users count 5 eventually") {
          await expect(viewModel.users.count).toEventually(equal(5))
          
          mockDataProvider.responseToReturn = Helper.loadLocalTestDataWithoutParsing("APIError", type: [User].self)
          mockDataProvider.errorToReturn = .unknown
          await expect(viewModel.users.count).toEventually(equal(5))
        }
      }
    }
    
    describe("searchUsers action") {
      beforeEach {
        mockDataProvider.responseToReturn = Helper.loadLocalTestDataWithoutParsing("UserList", type: [User].self)
        viewModel = UserListViewModel(dataProvider: mockDataProvider)
        viewModel.loadGitHubUsers()
      }
      
      context("searchUsers success") {
        it("should return search users count 2 eventually") {
          await expect(viewModel.users.count).toEventually(equal(5))
          
          mockDataProvider.responseToReturnSearch = Helper.loadLocalTestDataWithoutParsing("UserSearch", type: UsersSearch.self)
          viewModel.searchUsers(with: "keyur")
          await expect(viewModel.users.count).toEventually(equal(2))
        }
      }
      
      context("searchUsers failed") {
        it("should return search users count 0 eventually") {
          await expect(viewModel.users.count).toEventually(equal(5))
          
          mockDataProvider.responseToReturnSearch = Helper.loadLocalTestDataWithoutParsing("APIError", type: UsersSearch.self)
          mockDataProvider.errorToReturn = .unknown
          viewModel.searchUsers(with: "keyur")
          await expect(viewModel.users.count).toEventually(equal(0))
        }
      }
          
      context("userList pagination when isSearching true") {
        it("shouldn't call loadGitHubUsers and return same count") {
          await expect(viewModel.users.count).toEventually(equal(5))
          
          mockDataProvider.responseToReturnSearch = Helper.loadLocalTestDataWithoutParsing("UserSearch", type: UsersSearch.self)
          viewModel.searchUsers(with: "keyur")

          viewModel.loadGitHubUsers()
          await expect(viewModel.users.count).toEventually(equal(5))
        }
      }
    }
    
    describe("dismissSearchUsers action") {
      beforeEach {
        mockDataProvider.responseToReturn = Helper.loadLocalTestDataWithoutParsing("UserList", type: [User].self)
        viewModel = UserListViewModel(dataProvider: mockDataProvider)
        viewModel.loadGitHubUsers()
      }
      it("should return users count same as initial value") {
        await expect(viewModel.users.count).toEventually(equal(5))
        
        mockDataProvider.responseToReturnSearch = Helper.loadLocalTestDataWithoutParsing("UserSearch", type: UsersSearch.self)
        viewModel.searchUsers(with: "keyur")
        await expect(viewModel.users.count).toEventually(equal(2))
        
        viewModel.dismissSearchUsers()
        await expect(viewModel.users.count).toEventually(equal(5))
      }
    }
    
    describe("lastUserId") {
      beforeEach {
        mockDataProvider.responseToReturn = Helper.loadLocalTestDataWithoutParsing("UserList", type: [User].self)
        viewModel = UserListViewModel(dataProvider: mockDataProvider)
        viewModel.loadGitHubUsers()
      }
      it("should return correct value") {
        await expect(viewModel.lastUserId).toEventually(equal(54859))
      }
    }
  }
}
