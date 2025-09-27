//
//  Middleware.swift
//  ReduxKit
//
//  Created by Isaac Akalanne on 18/07/2025.
//

import Foundation

/// A generic function that for a given `State` and `Action`, interacts with the `Environment`, asynchronously returning an optional `Action`.
///
/// In the `Redux` architecture it is the `Middleware's` responsibility to communicate with the `Environment` in order to act on external dependancies.
///
/// - Parameters:
///   - State: The current state of the application.
///   - Action: The action which determines how the Middleware should behave (typically an enum).
///   - Environment: Any object outside of the Redux system. These are it's dependancies such as: local storage, repository.
public typealias Middleware<State, Action, Environment> = (State, Action, Environment) async -> Action?
