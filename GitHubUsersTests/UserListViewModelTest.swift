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
        }
        
        it("should return users count 0") {
          await expect(viewModel.users.count).toEventually(equal(0))
        }
      }
    }
    
    describe("loadGitHubUsers with pagination") {
      context("loadGitHubUsers success") {
        beforeEach {
          mockDataProvider.responseToReturn = Helper.loadLocalTestDataWithoutParsing("UserList", type: [User].self)
          viewModel = UserListViewModel(dataProvider: mockDataProvider)
        }
        
        it("should return correct users count 10 eventually") {
          await expect(viewModel.users.count).toEventually(equal(5))
          
          viewModel.loadGitHubUsers()
          await expect(viewModel.users.count).toEventually(equal(10))
        }
      }
      
      context("loadGitHubUsers failed") {
        beforeEach {
          mockDataProvider.responseToReturn = Helper.loadLocalTestDataWithoutParsing("UserList", type: [User].self)
          viewModel = UserListViewModel(dataProvider: mockDataProvider)
        }
        
        it("should return users count 5 eventually") {
          await expect(viewModel.users.count).toEventually(equal(5))
          
          mockDataProvider.responseToReturn = Helper.loadLocalTestDataWithoutParsing("APIError", type: [User].self)
          mockDataProvider.errorToReturn = .unknown
          await expect(viewModel.users.count).toEventually(equal(5))
        }
      }
    }
  }
}
