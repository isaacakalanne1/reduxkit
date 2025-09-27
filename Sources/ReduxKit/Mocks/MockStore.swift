//
//  MockStore.swift
//  ReduxKit
//
//  Created by Isaac Akalanne on 19/09/2025.
//

import Foundation
import Combine

/// A mock version of the Redux Store
///
/// Allows the Store to be mocked and interrogated in tests. This is intended to be used in testing only.
public class MockStore<State: Equatable, Action: Sendable, Environment>: Store<State, Action, Environment>, @unchecked Sendable {

    /// The last action to be dispatched by the ``MockStore``
    public var lastDispatchedAction = CurrentValueSubject<Action?, Never>(nil)

    /// An array of all the actions dispatched by the ``MockStore``, in chronological order.
    public var dispatchedActions = [Action]()

    /// Dispatch an `Action` into the `Redux` system
    ///
    /// - Parameters:
    ///   - action: The action to be handled by the ``Reducer`` and ``Middleware``
    public override func dispatch(_ action: Action) {
        dispatchedActions.append(action)
        lastDispatchedAction.send(action)
        
        super.dispatch(action)
    }
    
    // MARK: Async Action Fulfillment for Subscriptions
    
    /// Await the fulfillment of one or more actions.
    ///
    /// ```swift
    /// @Test func observe_deviceInControl() async {
    ///     await store.fulfillment(of: .startVehicle) {
    ///         self.parkingSession.deviceInControlSubject.send(.value(.deviceInControl))
    ///     }
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - action: The unordered list of expected actions.
    ///   - testBehavior: A test behavior to run after setting up the sequence.
    @available(iOS 15.0, *)
    @available(macOS 12.0, *)
    @available(watchOS 8.0, *)
    public func fulfillment(
        of action: Action...,
        execute testBehavior: @Sendable @escaping () async -> Void
    ) async where Action: Equatable {
        let task = Task {
            await self.processFulfillment(actions: action)
        }
        
        // Execute arbitrary code. This is where test behavior
        // after publisher setup should exist.
        Task {
            try await Task.sleep(nanoseconds: 10 * NSEC_PER_MSEC)
            await testBehavior()
        }
        
        // Assure the task completes.
        _ = await task.result
    }
    
    /// Await the fulfillment of one or more actions with a timeout.
    ///
    /// ```swift
    /// @Test func observe_vehicleStarted_multiple() async throws {
    ///     try await store.fulfillment(of: .startVehicle, .vehicleStarted, timeout: .seconds(1)) {
    ///         parkingSession.startupStatusSubject.send(.value(.active))
    ///         parkingSession.deviceInControlSubject.send(.value(.deviceInControl))
    ///     }
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - action: The unordered list of expected actions.
    ///   - timeout: The timeout that the actions must be fulfilled within.
    ///   - testBehavior: A test behavior to run after setting up the sequence.
    /// - Returns: The actions that were missing and not fulfilled.
    @discardableResult
    @available(iOS 15.0, *)
    @available(macOS 12.0, *)
    @available(watchOS 8.0, *)
    public func fulfillment(
        of action: Action...,
        timeout: TimeInterval,
        execute testBehavior: @Sendable @escaping () async -> Void
    ) async throws -> [Action] where Action: Equatable {
        let task = Task {
            let remaining = await self.processFulfillment(actions: action)
            do {
                try Task.checkCancellation()
            } catch {
                throw MockStoreError.timeout(unfulfilled: remaining)
            }
            return remaining
        }
        
        Task {
            try await Task.sleep(nanoseconds: UInt64(timeout) * NSEC_PER_SEC)
            task.cancel()
        }
        
        // Execute arbitrary test code. This is used to ensure
        Task {
            try await Task.sleep(nanoseconds: 10 * NSEC_PER_MSEC)
            await testBehavior()
        }
        
        return try await task.value
    }
    
    /// Await the fulfillment of one or more actions.
    ///
    /// - Parameter actions: The unordered list of expected actions.
    /// - Returns: The actions that were missing and not fulfilled.
    @available(iOS 15.0, *)
    @available(macOS 12.0, *)
    @available(watchOS 8.0, *)
    private func processFulfillment(actions: [Action]) async -> [Action] where Action: Equatable {
        var pendingFulfillment: [Action] = actions
        for await value in lastDispatchedAction.values {
            // Remove the value from pending fulfillment.
            if let match = pendingFulfillment.firstIndex(where: { $0 == value }) {
                pendingFulfillment.remove(at: match)
            }
            
            // Exit/End the AsyncSequence's await if all pending items have been found.
            if pendingFulfillment.isEmpty {
                break
            }
        }
        return pendingFulfillment
    }
}
