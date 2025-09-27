//
//  OnSubscribe.swift
//  ReduxKit
//
//  Created by Isaac Akalanne on 18/07/2025.
//

import Foundation

/// A function that is called `once` after the ``Store`` is initialised. Used to subscribe to any publishers that need to be observed by the Redux system.
///
/// Remember to
///
/// - Parameters:
///   - Store: The Redux ``Store``
///   - Environment: Any object outside of the Redux system. These are it's dependancies such as: local storage, repository.
public typealias OnSubscribe<Store, Environment> = (Store, Environment) -> Void
