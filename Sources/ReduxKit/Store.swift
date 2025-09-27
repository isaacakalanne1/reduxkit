//
//  Copyright © Jaguar Land Rover Ltd 2023 All rights reserved.
//  This software is confidential and proprietary information.
//

import Foundation
import Combine
import SwiftUI

/// The `Store` is the heart of the `Redux` architecture. It is the centralised location that holds the `Application State`.
///
/// This is the single source of truth for your app.
///
/// - Parameters:
///   - State: The current state of the application.
///   - Action: The action which determines how the Middleware should behave (typically an enum).
///   - Environment: Any object outside of the Redux system. These are it's dependancies such as: local storage, repository.
public class Store<State: Equatable, Action: Sendable, Environment>: ObservableObject {

    /// The current state of the application
    @Published public private(set) var state: State

    /// Any object outside of the Redux system. These are it's dependancies such as: local storage, repository.
    public private(set) var environment: Environment

    private let reducer: Reducer<State, Action>
    private let middleware: Middleware<State, Action, Environment>

    /// Subscriptions to publishers
    ///
    /// In the case where you need to observe changes in your environment, store your subscriptions in this object.
    ///
    /// ```swift
    /// let subscriber: OnSubscribe<SomeStore, SomeEnvironment> = { store, environment in
    ///         environment.somethingToObserve
    ///             .receive(on: RunLoop.main)
    ///             .sink(
    ///                 receiveCompletion: { _ in },
    ///                 receiveValue: { [weak store] value in
    ///                     store?.dispatch(.doSomething(with: value))
    ///                 }
    ///             )
    ///             .store(in: &store.subscriptions)
    ///     }
    /// }
    /// ```

    public var subscriptions: Set<AnyCancellable> = []
    
    /// Subscribe publishers
    ///
    /// In the case where you need to observe changes in your environment, use this function.
    ///
    /// ```swift
    /// let subscriber: OnSubscribe<SomeStore, SomeEnvironment> = { store, environment in
    ///         store.subscribe(
    ///             environment.somethingToObserve
    ///         ) { (store, value) in
    ///             store.dispatch(.doSomething(with: value))
    ///         }
    ///     }
    /// }
    /// ```
    public func subscribe<P: Publisher>(
        _ publisher: P,
        receiveCompletion: ((Subscribers.Completion<P.Failure>) -> Void)? = nil,
        receiveValue: @escaping ((Store<State, Action, Environment>, P.Output) -> Void)
    ) {
        publisher
            .receive(on: reduxScheduler)
            .sink(receiveCompletion: { completion in
                receiveCompletion?(completion)
            }, receiveValue: { [weak self] value in
                guard let self else {
                    return
                }
                receiveValue(self, value)
            })
            .store(in: &subscriptions)
    }

    /// Initialise an instance of the Store
    ///
    /// - Parameters:
    ///   - initial: The initial state of the application.
    ///   - reducer: The ``Reducer``
    ///   - environment: Any object outside of the Redux system. These are it's dependancies such as: local storage, repository.
    ///   - middleware: The ``Middleware`` function
    ///   - subscriber: The ``OnSubscribe`` function
    public init(initial: State,
                reducer: @escaping Reducer<State, Action>,
                environment: Environment,
                middleware: @escaping Middleware<State, Action, Environment>,
                subscriber: OnSubscribe<Store, Environment> = { _, _ in }) {
        self.state = initial
        self.reducer = reducer
        self.environment = environment
        self.middleware = middleware
        
        subscriber(self, environment)
    }

    /// Dispatch an `Action` into the `Redux` system
    ///
    /// - Parameters:
    ///   - action: The action to be handled by the ``Reducer`` and ``Middleware``
    @MainActor
    public func dispatch(_ action: Action) {
        DispatchQueue.main.async {
            self.dispatch(self.state, action)
        }
    }
    
    @MainActor
    private func dispatch(_ currentState: State, _ action: Action) {
        let newState = self.reducer(currentState, action)
        let stateChanged = newState != state
        if stateChanged {
            self.state = newState
        }
        
        // Execute middleware asynchronously
        Task { @MainActor in
            if let newAction = await middleware(stateChanged ? newState : self.state, action, environment) {
                self.dispatch(self.state, newAction)
            }
        }
    }
}
