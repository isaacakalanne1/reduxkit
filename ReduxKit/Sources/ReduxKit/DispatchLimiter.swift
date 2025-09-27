//
//  DispatchLimiter.swift
//  FlowTale
//
//  Created by iakalann on 18/07/2025.
//

import Combine
import Foundation
import CombineSchedulers

/// This object is intended to be used within the UI layer to limit the amount of times an action can be dispatched to the store by the UI
/// It must be held as @StateObject in your SwiftUI view so that the object is not recreated when the view is redrawn
///
/// ```
/// @StateObject var dispatchLimiter = DispatchLimiter()
///
/// Button("Press me", action: {
///     dispatchLimiter.dispatch {
///         store.dispatch(.action)
///     }
/// })
/// ```
public class DispatchLimiter: ObservableObject {
    let dispatchPublisher: PassthroughSubject<(() -> Void), Never> = .init()
    var cancellable: AnyCancellable!
    let waitPeriod: TimeInterval

    /// Initialise a `DispatchLimiter` with a specified wait period
    ///
    /// - Parameters:
    ///   - waitPeriod: If no calls have been made to ``dispatch(_:)`` within this time period, the last closure passed to ``dispatch(_:)`` will be executed
    public convenience init(waitPeriod: TimeInterval = 1) {
        self.init(waitPeriod: waitPeriod, scheduler: .main)
    }

    init(waitPeriod: TimeInterval, scheduler: AnySchedulerOf<DispatchQueue>) {
        self.waitPeriod = waitPeriod
        cancellable = dispatchPublisher
            .debounce(for: .seconds(waitPeriod), scheduler: scheduler)
            .sink { request in
                request()
            }
    }

    /// Dispatch an action to be performed
    ///
    /// - Parameters:
    ///   - action: The closure (action) to be performed once the wait period has timed out
    public func dispatch(_ action: @escaping () -> Void) {
        dispatchPublisher.send(action)
    }
}
