//
//  UserDetailsViewModelTest.swift
//  GitHubUsersTests
//
//  Created by Keyur Bhalodiya on 2024/06/26.
//

import Foundation
import Quick
import Nimble

@testable import GitHubUsers

final class UserDetailsViewModelTest: AsyncSpec {
  override class func spec() {
    var viewModel: UserDetailsViewModel!
    var mockDataProvider: MockUserDetailsViewDataProvider!
    beforeEach {
      mockDataProvider = MockUserDetailsViewDataProvider()
    }
    
    
    describe("load UserInfo and Repo on first launch") {
      context("fetchUserInfo and loadRepo success") {
        beforeEach {
          mockDataProvider.responseToReturnUserInfo = Helper.loadLocalTestDataWithoutParsing("UserInfo", type: UserInfo.self)
          mockDataProvider.responseToReturnRepos = Helper.loadLocalTestDataWithoutParsing("UserRepo", type: [UserRepositories].self)
          viewModel = UserDetailsViewModel(loginUsername: "mojombo", dataProvider: mockDataProvider)
        }
        
        it("should return correct value and repo count") {
          await expect(viewModel.userInfo?.name).toEventually(equal("Tom Preston-Werner"))
          await expect(viewModel.userInfo?.login).toEventually(equal("mojombo"))
          await expect(viewModel.userInfo?.followers).toEventually(equal(23918))
          await expect(viewModel.userInfo?.following).toEventually(equal(11))
          await expect(viewModel.userInfo?.location).toEventually(equal("San Francisco"))
          await expect(viewModel.repos.count).toEventually(equal(5))
        }
      }
      
      context("load UserInfo failed") {
        beforeEach {
          mockDataProvider.responseToReturnUserInfo = Helper.loadLocalTestDataWithoutParsing("APIError", type: UserInfo.self)
          mockDataProvider.responseToReturnRepos = Helper.loadLocalTestDataWithoutParsing("UserRepo", type: [UserRepositories].self)
          mockDataProvider.errorToReturn = .unknown
          viewModel = UserDetailsViewModel(loginUsername: "mojombo", dataProvider: mockDataProvider)
        }
        
        it("should return nil for user info") {
          await expect(viewModel.userInfo?.name).toEventually(beNil())
          await expect(viewModel.userInfo?.login).toEventually(beNil())
          await expect(viewModel.userInfo?.followers).toEventually(beNil())
          await expect(viewModel.userInfo?.following).toEventually(beNil())
          await expect(viewModel.userInfo?.location).toEventually(beNil())
          await expect(viewModel.repos.count).toEventually(equal(5))
        }
      }
      
      context("loadRepo failed") {
        beforeEach {
          mockDataProvider.responseToReturnUserInfo = Helper.loadLocalTestDataWithoutParsing("UserInfo", type: UserInfo.self)
          mockDataProvider.responseToReturnRepos = Helper.loadLocalTestDataWithoutParsing("APIError", type: [UserRepositories].self)
          mockDataProvider.errorToReturn = .unknown
          viewModel = UserDetailsViewModel(loginUsername: "mojombo", dataProvider: mockDataProvider)
        }
        
        it("should return repos count 0") {
          await expect(viewModel.userInfo?.name).toEventually(equal("Tom Preston-Werner"))
          await expect(viewModel.userInfo?.login).toEventually(equal("mojombo"))
          await expect(viewModel.userInfo?.followers).toEventually(equal(23918))
          await expect(viewModel.userInfo?.following).toEventually(equal(11))
          await expect(viewModel.repos.count).toEventually(equal(0))
        }
      }
    }
    
    describe("loadRepo with pagination") {
      context("loadRepo success") {
        beforeEach {
          mockDataProvider.responseToReturnRepos = Helper.loadLocalTestDataWithoutParsing("UserRepo", type: [UserRepositories].self)
          viewModel = UserDetailsViewModel(loginUsername: "mojombo", dataProvider: mockDataProvider)
        }
        
        it("should return correct users count 10 eventually") {
          await expect(viewModel.repos.count).toEventually(equal(5))
          
          viewModel.loadGitRepos()
          await expect(viewModel.repos.count).toEventually(equal(10))
        }
      }
      
      context("loadRepo failed") {
        beforeEach {
          mockDataProvider.responseToReturnRepos = Helper.loadLocalTestDataWithoutParsing("UserRepo", type: [UserRepositories].self)
          viewModel = UserDetailsViewModel(loginUsername: "mojombo", dataProvider: mockDataProvider)
        }
        
        it("should return users count 5 eventually") {
          await expect(viewModel.repos.count).toEventually(equal(5))
          
          mockDataProvider.responseToReturnRepos = Helper.loadLocalTestDataWithoutParsing("APIError", type: [UserRepositories].self)
          mockDataProvider.errorToReturn = .unknown
          await expect(viewModel.repos.count).toEventually(equal(5))
        }
      }
    }
  }
}
