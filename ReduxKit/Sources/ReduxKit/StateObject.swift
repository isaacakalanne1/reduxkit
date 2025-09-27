//
//  StateObject.swift
//  ReduxKit
//
//  Created by Isaac Akalanne on 18/07/2025.
//

import Foundation
import SwiftUI

@available(iOS 14.0, *)
@available(macOS 12.0, *)
@available(macCatalyst 14.0, *)
@available(tvOS 14.0, *)
@available(watchOS 7.0, *)
extension StateObject {
    
    /// Creates a new state object with an initial wrapped value.
    ///
    /// ### Important Redux Notes
    ///
    /// The default `StateObject(wrappedValue: @autoclosure @escaping () -> ObjectType)`
    /// uses an auto closure to only call the wrappedValue creation closure **once per
    /// view appearance lifecycle**. To avoid undefined behavior, all redux environment environment
    /// creation should be done inside this closure to avoid repeated inits on redraw.
    ///
    /// ```swift
    /// @StateObject private var store: SomeStore
    ///
    /// // An init for a SwiftUI Root View
    /// init(someServiceParent: SomeServiceParentType, otherService: OtherService) {
    ///     // Code at this level is run every time the view hierarchy state changes to redraw.
    ///     _store = StateObject {
    ///        // Code at this level is only called once when the view appears.
    ///
    ///        let someService = SomeService(using: someServiceParent)
    ///        let environment = SomeEnvironment(
    ///            someService: someService,
    ///            otherService: otherService
    ///        )
    ///
    ///        let initialState = HomeState(
    ///            someValue: someService.someValue,
    ///        )
    ///
    ///        return SomeStore(
    ///            initial: initialState,
    ///            reducer: someReducer,
    ///            environment: environment,
    ///            middleware: someMiddleware,
    ///            subscriber: someSubscriber
    ///        )
    ///     }
    /// }
    /// ```
    ///
    /// - Parameter buildWrappedValue: A closure that initializes all objects related to a state object.
    public init(buildWrappedValue: @escaping () -> ObjectType) {
        self.init(wrappedValue: buildWrappedValue())
    }
}
