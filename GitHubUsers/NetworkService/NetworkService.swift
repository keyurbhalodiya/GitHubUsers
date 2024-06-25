//
//  NetworkService.swift
//  GitHubUsers
//
//  Created by Keyur Bhalodiya on 2024/06/23.
//

import Foundation
import Combine

private enum NetworkError: Error {
    case invalidURL
    case responseError
    case unknown
}

extension NetworkError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return NSLocalizedString("Invalid URL", comment: "")
        case .responseError:
            return NSLocalizedString("Unexpected status code", comment: "")
        case .unknown:
            return NSLocalizedString("Unknown error", comment: "")
        }
    }
}

private enum Constant {
  static let token = "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"
  static let baseUrl = "https://api.github.com/"
}

final class NetworkService {
  
  static let shared = NetworkService()
  
  private var cancellables = Set<AnyCancellable>()
  
  func getData<T: Decodable>(endpoint: String, parameters: [String : Any], type: T.Type) -> Future<T, Error> {
    
    return Future<T, Error> { [weak self] promise in
      guard let self = self, let url = URL(string: "\(Constant.baseUrl + endpoint)") else {
        return promise(.failure(NetworkError.invalidURL))
      }
      var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
      components?.queryItems = parameters.map { (key, value) in
        URLQueryItem(name: key, value: "\(value)")
      }
      
      guard let componentsUrl = components?.url else {
        return promise(.failure(NetworkError.invalidURL))
      }
      
      var request = URLRequest(url: componentsUrl)
      request.httpMethod = "GET"
      request.addValue("Bearer \(Constant.token)", forHTTPHeaderField: "Authorization")
      URLSession.shared.dataTaskPublisher(for: request)
        .tryMap { (data, response) -> Data in  // -> Operator
          guard let httpResponse = response as? HTTPURLResponse, 200...299 ~= httpResponse.statusCode else {
            throw NetworkError.responseError
          }
          return data
        }
        .decode(type: T.self, decoder: JSONDecoder())  // -> Operator
        .receive(on: RunLoop.main) // -> Sheduler Operator
        .sink(receiveCompletion: { (completion) in  // -> Subscriber
          if case let .failure(error) = completion {
            switch error {
            case let decodingError as DecodingError:
              promise(.failure(decodingError))
            case let apiError as NetworkError:
              promise(.failure(apiError))
            default:
              promise(.failure(NetworkError.unknown))
            }
          }
        }, receiveValue: {  data in
          promise(.success(data)
          ) })
        .store(in: &self.cancellables)
    }
  }
}
