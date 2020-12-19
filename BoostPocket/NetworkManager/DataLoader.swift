//
//  DataLoader.swift
//  BoostPocket
//
//  Created by sihyung you on 2020/11/23.
//  Copyright © 2020 BoostPocket. All rights reserved.
//

import Foundation

protocol DataLoadable {
    var session: URLSession { get }
    var requestURL: URL? { get }
    func requestExchangeRate(url: String, completion: @escaping (Result<ExchangeRate, NetworkError>) -> Void)
    func convertToURL(url: String) -> URL?
}

public class DataLoader: DataLoadable {
    var session: URLSession
    var requestURL: URL?
    
    public init(session: URLSession) {
        self.session = session
    }
    
    public func requestExchangeRate(url: String, completion: @escaping (Result<ExchangeRate, NetworkError>) -> Void) {
        guard let requestURL = convertToURL(url: url) else {
            completion(.failure(.invalidURL("유효하지 않은 주소입니다.")))
            return
        }
        
        session.dataTask(with: requestURL) { data, _, error in
            guard error == nil, let data = data else {
                completion(.failure(.networkError(error!)))
                return
            }
            
            do {
                let jsonDecoder = JSONDecoder()
                let exchangeRates = try jsonDecoder.decode(ExchangeRate.self, from: data)
//                print("환율 정보 요청 성공")
                completion(.success(exchangeRates))
            } catch {
//                print("환율 정보 요청 실패")
                completion(.failure(.decodingError(error)))
            }
        }.resume()
    }
    
    public func convertToURL(url: String) -> URL? {
        guard let validURL = URL(string: url) else { return nil }
        
        return validURL
    }
}

class DataLoaderStub: DataLoadable {
    var session: URLSession
    var requestURL: URL?
    
    init(session: URLSession) {
        self.session = session
    }
    
    func requestExchangeRate(url: String, completion: @escaping (Result<ExchangeRate, NetworkError>) -> Void) {
        guard let validURL = convertToURL(url: url) else {
            completion(.failure(.invalidURL("유효하지 않은 주소입니다.")))
            return
        }

        requestURL = validURL
    }
    
    func convertToURL(url: String) -> URL? {
        guard let validURL = URL(string: url) else { return nil }
        
        return validURL
    }
}

public enum NetworkError: Error {
    case networkError(Error)
    case invalidURL(String)
    case decodingError(Error)
    case imageIsNil(Error)
}

public struct ExchangeRate: Codable {
    public let rates: [String: Double]
    public let base: String
    public let date: String
}
