# SDNetwork
This is a lightweight Swift network layer using URLSession for making HTTP requests.
It simplifies common networking tasks and handles basic error scenarios.

## Table of Contents
- [HTTPMethod Enum](#httpmethod-enum)
- [HTTPEndpoint Protocol](#httpendpoint-protocol)
- [NetworkError Enum](#networkerror-enum)
- [Example Usage](#example-usage)

### HTTPMethod Enum
```swift
enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}
```
The HTTPMethod enum defines common HTTP methods for network requests.

### HTTPEndpoint Protocol
```swift
protocol HTTPEndpoint {
    var scheme: String { get }
    var host: String { get }
    var method: HTTPMethod { get }
    var path: String { get }
    var headers: [(value: String, forField: String)] { get }
    var queryItems: [URLQueryItem] { get }
    var httpBody: Data? { get }
}
```
The HTTPEndpoint protocol outlines the structure of an HTTP endpoint, allowing customization of various components such as scheme, host, method, path, headers, query parameters, and request body.

### NetworkError Enum
```swift
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
```
The NetworkError enum enumerates common networking errors and provides descriptive error messages.

### Example Usage
```swift
// Creating a custom endpoint
enum CustomEndpoint: HTTPEndpoint {
    case customPath(parameter: String)

    var scheme: String {
        return "https"
    }

    var host: String {
        return "example.com"
    }

    var method: HTTPMethod {
        return .get
    }

    var path: String {
        switch self {
        case .customPath(let parameter):
            return "/api/\(parameter)"
        }
    }

    var headers: [(value: String, forField: String)] {
        return [
            ("application/json", "Content-Type"),
            ("application/json", "Accept"),
        ]
    }

    var queryItems: [URLQueryItem] {
        return []
    }

    var httpBody: Data? {
        return nil
    }
}

// Creating a middle layer class
class CustomService {
    private let service: ServiceProtocol

    init(service: ServiceProtocol) {
        self.service = service
    }

    func requestCustomPath(parameter: String, completion: @escaping (Result<YourResponseType, NetworkError>) -> Void) {
        let endpoint = CustomEndpoint.customPath(parameter: parameter)
        service.request(with: endpoint, completion: completion)
    }
}

// Example usage
let customService = CustomService(service: Service())
customService.requestCustomPath(parameter: "example") { result in
    switch result {
    case .success(let response):
        // Handle successful response
        print(response)
    case .failure(let error):
        // Handle error
        print("Error: \(error.localizedDescription)")
    }
}

// Example usage without middle layer
let service = Service()
service.request(endpoint: CustomEndpoint.customPath(parameter: "Parameter")) { result in
    switch result {
    case .success(let response):
        // Handle successful response
        print(response)
    case .failure(let error):
        // Handle error
        print("Error: \(error.localizedDescription)")
    }
}
```

This example demonstrates how to create a middle layer class (CustomService) with custom endpoints allowing users for more advanced use cases.
Additionally, users can still directly call service.request with their created customized endpoints.







