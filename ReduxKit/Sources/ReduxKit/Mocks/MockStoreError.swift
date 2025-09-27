//
//  MockStoreError.swift
//  ReduxKit
//
//  Created by Isaac Akalanne on 19/09/2025.
//

import Foundation

/// Test errors that have occured on the MockStore.
public enum MockStoreError<A: Sendable>: Error {
    
    /// The test has timedout before all expected actions were fulfilled.
    case timeout(unfulfilled: [A])
}

extension MockStoreError: LocalizedError {
    public var errorDescription: String? {
        switch self {
            
        case .timeout(unfulfilled: let unfulfilled):
            let actions = unfulfilled.map { ".\($0)" }
                .joined(separator: ", ")
            return "Test timed out before \(actions) were fulfilled."
        }
    }
}
