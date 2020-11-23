//
//  DataLoader.swift
//  BoostPocket
//
//  Created by sihyung you on 2020/11/23.
//  Copyright © 2020 BoostPocket. All rights reserved.
//

import Foundation

struct ExchangeRate: Codable {
    let rates: [String: Float]
    let base: String
    let date: String
}

protocol DataLoadable {
    var requestURL: URL? { get }
    func requestExchangeRate(url: String, completion: @escaping (Result<ExchangeRate?, NetworkError>) -> Void)
    func converToURL(url: String) -> URL?
}

//class DataLoader: DataLoadable {
//    var requestURL: URL?
//
//    func requestExchangeRate(url: URL, completion: @escaping (ExchangeRate?) -> Void) {
//        // 실제 URLSession을 통한 HTTP Request
//    }
//
//}

class DataLoaderStub: DataLoadable {
    
    var requestURL: URL?
    
    func requestExchangeRate(url: String, completion: @escaping (Result<ExchangeRate?, NetworkError>) -> Void) {
        // 성공/실패에 대한 completion만 넘겨주기
        // 혹은 request param에 대한 일치여부만 확인
    }
    
    func converToURL(url: String) -> URL? {
        guard let validURL = URL(string: url) else {
            return nil
        }
        
        return validURL
    }
}

public enum NetworkError: Error {
    case invalidURL(String)
    case decodingError(Error)
    case imageIsNil
}
