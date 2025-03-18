//
//  CustomErrors.swift
//  Planner Application Draft
//
//

import Foundation

enum APIError: Error {
    case invalidURL (String)
    case responseError (Int)
    case invalidData
    case invalidResponse
    case taskFailed (String)
    case unknown(String)
    
    var errorMessage: String {
        switch self {
        case .invalidURL(let invalidURL):
            return "\(invalidURL) is an invalid URL"
        case .responseError (let statusCode):
            return "Response status code: \(statusCode)"
        case .invalidData:
            return "Data is invalid"
        case .invalidResponse:
            return "Response is invalid"
        case .taskFailed(let errorMessage):
            return "Task failed: \(errorMessage)"
        case .unknown(let errorMessage):
            return "Unknown: \(errorMessage)"
        }
    }
}
