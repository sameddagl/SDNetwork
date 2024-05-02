# SDNetwork
This is a lightweight Swift network layer using URLSession for making HTTP requests.
It simplifies common networking tasks and handles basic error scenarios.

## Table of Contents
- [HTTPMethod Enum](#httpmethod-enum)
- [HTTPEndpoint Protocol](#httpendpoint-protocol)
- [NetworkError Enum](#networkerror-enum)
- [How to use?](#how-to-use)

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
public enum NetworkError: LocalizedError {
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
            return "Failed with underlying error: \(error.localizedDescription)"
        }
    }
}
```
The NetworkError enum enumerates common networking errors and provides descriptive error messages.

### <a id="how-to-use"></a> How to use?
- #### Add SDNetwork to your project via SPM
```swift
https://github.com/sameddagl/SDNetwork
```

- #### Create an enpoint according to your api.
```swift
import SDNetwork

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
```

- #### Create a middle class for the endpoint.
```swift
import SDNetwork

class CustomService {
    private let service: ServiceProtocol

    init(service: ServiceProtocol) {
        self.service = service
    }

    // Using Completion Block
    func requestCustomPath(parameter: String, completion: @escaping (Result<YourResponseType, NetworkError>) -> Void) {
        let endpoint = CustomEndpoint.customPath(parameter: parameter)
        service.request(with: endpoint, completion: completion)
    }

    // Using Async-Await
    func requestCustomPathUsingAsyncAwait(parameter: String) async throws -> YourResponseType {
        let endpoint = CustomEndpoint.customPath(parameter: parameter)
        return try await service.request(with: endpoint)
    }
}
```

- #### Use mid class to make a request.
```swift
import SDNetwork

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







