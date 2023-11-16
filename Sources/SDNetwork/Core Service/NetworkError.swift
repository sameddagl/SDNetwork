//
//  NetworkError.swift
//
//
//  Created by Samed Dağlı on 16.11.2023.
//

import Foundation

public enum NetworkError: Error {
    case wrongURLFormat
    case invalidServerResponseWithStatusCode(statusCode: Int)
    case invalidServerResponse
    case missingData
    case decodingError(Error)
    case connectionError(Error)
    case underlying(Error)
}

public extension NetworkError {
     var errorDescription: String {
        switch self {
        case .wrongURLFormat:
            return "URL format is wrong."
        case .invalidServerResponseWithStatusCode(let statusCode):
            return "The server response didn't fall in the given range Status Code is: \(statusCode)"
        case .invalidServerResponse:
            return "Failed to parse the response to HTTPResponse"
        case .missingData:
            return "No body data provided from the server"
        case .decodingError(let error):
            return "Decoding problem: \(error.localizedDescription)"
        case .connectionError(let error):
            return "Network connection seems to be offline: \(error.localizedDescription)"
        case .underlying(let error):
            return error.localizedDescription
        }
    }
}
