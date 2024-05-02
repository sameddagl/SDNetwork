//
//  Service.swift
//
//
//  Created by Samed Dağlı on 16.11.2023.
//

import Foundation

public protocol URLSessionProtocol {
    func dataTask(with request: URLRequest, completionHandler: @escaping @Sendable (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask
}

extension URLSession: URLSessionProtocol {}

public protocol ServiceProtocol {
    func request<T: Decodable>(with endpoint: HTTPEndpoint, completion: @escaping(Result<T, NetworkError>) -> Void)
}

public final class Service: ServiceProtocol {
    private let urlSession: URLSessionProtocol
    private let decoder: JSONDecoder
    
    public init(urlSession: URLSessionProtocol = URLSession.shared, decoder: JSONDecoder = JSONDecoder()) {
        self.urlSession = urlSession
        self.decoder = decoder
    }
    
    public func request<T: Decodable>(with endpoint: HTTPEndpoint, completion: @escaping (Result<T, NetworkError>) -> Void) {
        do {
            let urlRequest = try createURLRequest(with: endpoint)
            performRequest(with: urlRequest, completion: completion)
        } catch let error as NetworkError {
            #if DEBUG
                print(error)
            #endif
            completion(.failure(error))
        } catch let error {
            #if DEBUG
                print(error)
            #endif
            completion(.failure(.underlying(error)))
        }
    }
    
    public func request<T: Decodable>(with endpoint: HTTPEndpoint) async throws -> T {
        return try await withCheckedThrowingContinuation { continuation in
            request(with: endpoint) { result in
                return continuation.resume(with: result)
            }
        }
    }
    
    private func performRequest<T: Decodable>(with request: URLRequest, completion: @escaping (Result<T, NetworkError>) -> Void) {
        urlSession.dataTask(with: request) { data, response, error in
            if let error {
                #if DEBUG
                    print(error)
                #endif
                completion(.failure(.underlying(error)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                #if DEBUG
                    print(NetworkError.invalidServerResponse.errorDescription)
                #endif
                completion(.failure(.invalidServerResponse))
                return
            }
            
            guard let data = data else {
                #if DEBUG
                    print(NetworkError.missingData)
                #endif
                completion(.failure(.missingData))
                return
            }
            
            switch httpResponse.statusCode {
            case 200...299:
                do {
                    let decodedData = try self.decoder.decode(T.self, from: data)
                    completion(.success(decodedData))
                } catch let error {
                    #if DEBUG
                        print(error)
                    #endif
                    completion(.failure(.decodingError(error)))
                }
            default:
                #if DEBUG
                    print(NetworkError.invalidServerResponseWithStatusCode(statusCode: httpResponse.statusCode))
                #endif
                completion(.failure(.invalidServerResponseWithStatusCode(statusCode: httpResponse.statusCode)))
            }
        }.resume()
    }
    
    private func createURLComponents(with endpoint: HTTPEndpoint) -> URLComponents {
        var components = URLComponents()
        components.scheme = endpoint.scheme
        components.host = endpoint.host
        components.path = endpoint.path
        components.queryItems = endpoint.queryItems
        return components
    }
    
    private func createURLRequest(with endpoint: HTTPEndpoint) throws -> URLRequest {
        let urlComponents = createURLComponents(with: endpoint)
        
        guard let url = urlComponents.url else {
            throw NetworkError.wrongURLFormat
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = endpoint.method.rawValue
        urlRequest.httpBody = endpoint.httpBody
        
        for (value, field) in endpoint.headers {
            urlRequest.setValue(value, forHTTPHeaderField: field)
        }
        
        return urlRequest
    }
}
