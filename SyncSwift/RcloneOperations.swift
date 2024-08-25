import Foundation

public struct RcloneOperations {
    public static let apiClient = APIClient()
    
    public static func sync(source: String, destination: String) -> String {
        return run(operation: "sync", source: source, destination: destination)
    }
    
    public static func copy(source: String, destination: String) -> String {
        return run(operation: "copy", source: source, destination: destination)
    }
    
    public static func move(source: String, destination: String) -> String {
        return run(operation: "move", source: source, destination: destination)
    }
    
//    public static func list() -> [String] {
//        self.apiClient.fetchRemotes { result in
//            
//        }
//        return ["foo"]
//    }

    static func run(operation: String, source: String, destination: String) -> String {
        ""
    }

}

public struct APIClient {
    private let baseURL = "http://localhost:5572"
    private let session = URLSession.shared
    
    public func fetchRemotes(completion: @escaping (Result<Remotes, Error>) -> Void) {
        let url = URL(string: "\(baseURL)/config/listremotes")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(APIError.noData))
                return
            }
            
            if let string = String(data: data, encoding: .utf8) {
                print("fetch: \(string)")
            } else {
                print("fetch: Could not decode data to string")
            }

            let result = Result { try JSONDecoder().decode(Remotes.self, from: data) }
            
            completion(result)

        }
        
        task.resume()
    }
        
    public func fetchConfigurations(completion: @escaping (Result<[Configuration], Error>) -> Void) {
        let url = URL(string: "\(baseURL)/configurations")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(APIError.noData))
                return
            }
            
            let result = Result { try JSONDecoder().decode([Configuration].self, from: data) }
            completion(result)

        }
        
        task.resume()
    }
    
    public func createConfiguration(_ config: Configuration, completion: @escaping (Result<Configuration, Error>) -> Void) {
        let url = URL(string: "\(baseURL)/config/???")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encodingResult = Result { try JSONEncoder().encode(config) }
        
        switch encodingResult {
        case .success(let jsonData):
            request.httpBody = jsonData
        case .failure(let error):
            completion(.failure(error))
            return
        }

        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(APIError.noData))
                return
            }
            
            do {
                let createdConfig = try JSONDecoder().decode(Configuration.self, from: data)
                completion(.success(createdConfig))
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
}

public struct Configuration: Codable {
    public let id: String
    public let name: String
    public let source: String
    public let destination: String
    
    public init(id: String, name: String, source: String, destination: String) {
        self.id = id
        self.name = name
        self.source = source
        self.destination = destination
    }
}

public struct Remotes: Codable {
    public let remotes: [String]
    
    public init(remotes: [String]) {
        self.remotes = remotes
    }
}

public enum APIError: Error {
    case noData
}
