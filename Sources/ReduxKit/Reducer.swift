//
//  Reducer.swift
//  ReduxKit
//
//  Created by Isaac Akalanne on 18/07/2025.
//

import Foundation

/// A generic function that for a given `State` and `Action`, returns a new `State`
///
/// In the `Redux` architecture it is the sole responsibility of the `Reducer` to mutate the `Application State`
///
/// - Parameters:
///   - State: The current state of the application.
///   - Action: The action which determines how the Reducer should mutate the State.
public typealias Reducer<State, Action> = (State, Action) -> State
