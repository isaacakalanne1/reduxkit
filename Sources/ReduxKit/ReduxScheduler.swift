//
//  ReduxScheduler.swift
//  ReduxKit
//
//  Created by Isaac Akalanne on 29/07/2025.
//

import Foundation

/// A global scheduler for use with subscriptions contained in the `OnSubscribe` closure.
/// The purpose of this is to discourage use of `.receive(on: DispatchQueue.main)` and `.receive(on: RunLoop.main)`.
/// This allows us to offload work from the main actor which was happening inside some Combine `.map` and `.sink` blocks.
/// ```swift
///    environment.somethingToObserve
///        .receive(on: reduxScheduler)
///        .sink(
///            receiveCompletion: { _ in },
///            receiveValue: { [weak store] value in
///                store?.dispatch(.doSomething(with: value))
///        })
///        .store(in: &store.subscriptions)
///     }
/// ```
public let reduxScheduler = DispatchQueue(label: "Redux-Scheduler", target: DispatchQueue.global(qos: .utility))
