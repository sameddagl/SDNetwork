//
//  HTTPEndpoint.swift
//
//
//  Created by Samed Dağlı on 16.11.2023.
//

import Foundation

public protocol HTTPEndpoint {
    var scheme: String { get }
    var host: String { get }
    var method: HTTPMethod { get }
    var path: String { get }
    var headers: [(value: String, forField: String)] { get }
    var queryItems: [URLQueryItem] { get }
    var httpBody: Data? { get }
}
