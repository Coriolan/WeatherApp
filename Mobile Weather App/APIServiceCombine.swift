//
//  APIServiceCombine.swift
//  Mobile Weather App
//
//  Created by Coriolan on 2024-06-27.
//

import Combine
import Foundation

public class APIServiceCombine {
    
    public static let shared = APIServiceCombine()
    var cancellable = Set<AnyCancellable>()
    public enum APIError: Error {
        case error(_ errorString: String)
    }
    
    public func getJSON<T: Decodable>(urlString: String,
                                      dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .deferredToDate,
                                      keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys,
                                      completion: @escaping (Result<T,APIError>) -> Void) {
//        print(">>>\(#function)")
//        print(">>>urlString: \(urlString)")
        guard let url = URL(string: urlString) else {
            completion(.failure(.error(">>>ERROR: Invalid URL")))
            return
        }
        
        let request = URLRequest(url: url)
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = dateDecodingStrategy
        decoder.keyDecodingStrategy = keyDecodingStrategy
        
        URLSession.shared.dataTaskPublisher(for: request)
            .map { $0.data }
            .decode(type: T.self, decoder: decoder)
            .receive(on: RunLoop.main)
            .sink { taskCompletion in
                switch taskCompletion {
                case .finished:
                    return
                case .failure(let decodingError):
                    completion(.failure(APIError.error(">>>ERROR: \(decodingError.localizedDescription)")))
                }
            } receiveValue: { decodedData in
                completion(.success(decodedData))
            }
            .store(in: &cancellable)

        
        
        
        /*URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.error(">>>ERROR: \(error.localizedDescription)")))
                return
            }
            
            guard let data = data else {
                completion(.failure(.error(">>>ERROR: Data is corrupt")))
                return
            }
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = dateDecodingStrategy
            decoder.keyDecodingStrategy = keyDecodingStrategy
            do {
                let decodedData = try decoder.decode(T.self, from: data)
                completion(.success(decodedData))
                return
            } catch let decodingError {
                completion(.failure(APIError.error(">>>ERROR: \(decodingError.localizedDescription)")))
                return
            }
        }.resume()*/
    }
}
