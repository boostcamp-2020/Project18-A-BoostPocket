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
    func converToURL(url: String) -> URL?
}

class DataLoader: DataLoadable {
    var session: URLSession
    var requestURL: URL?
    
    init(session: URLSession) {
        self.session = session
    }
    
    func requestExchangeRate(url: String, completion: @escaping (Result<ExchangeRate, NetworkError>) -> Void) {
        guard let requestURL = converToURL(url: url) else {
            completion(.failure(.invalidURL("유효하지 않은 주소입니다.")))
            return
        }
        
        // 실제 요청
        session.dataTask(with: requestURL) { data, _, error in
            guard error == nil, let data = data else {
                completion(.failure(.networkError(error!)))
                return
            }
            
            do {
                let jsonDecoder = JSONDecoder()
                let exchangeRates = try jsonDecoder.decode(ExchangeRate.self, from: data)
                completion(.success(exchangeRates))
            } catch {
                completion(.failure(.decodingError(error)))
            }
        }.resume()
    }
    
    func converToURL(url: String) -> URL? {
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
        requestURL = converToURL(url: url)
    }
    
    func converToURL(url: String) -> URL? {
        guard let validURL = URL(string: url) else { return nil }
        
        return validURL
    }
}

public enum NetworkError: Error {
    case networkError(Error)
    case invalidURL(String)
    case decodingError(Error)
    case imageIsNil
}

struct ExchangeRate: Codable {
    let rates: [String: Float]
    let base: String
    let date: String
}
