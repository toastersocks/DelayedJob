//
//  DelayedJob.swift
//
//
//  Created by James Pamplona on 7/2/19.
//  Copyright © 2019 James Pamplona. All rights reserved.

import typealias Foundation.TimeInterval
import struct Foundation.Date
import Dispatch

@available(macOS 10.12, *)

/// Represents a task that can be run at a later time. Ensures that a task is only run once if there is already another run of the taski pending.
public class DelayedJob {
    
    private let job: () -> Void
    private lazy var workItem = DispatchWorkItem { self.job(); self.status = .idle }
    private let queue = DispatchQueue(
        label: "DelayedJob",
        qos: .default,
        attributes: .concurrent,
        autoreleaseFrequency: .workItem,
        target: nil)
    private var status: Status = .idle
    private let priority: SoonerOrLater
    
    
    /// Creates a new delayed job with the specified closure and priority.
    /// - Parameter prioritize: Sets whether tasks that are scheduled sooner are prioritized over tasks that are scheduled for later or vise-versa.
    /// - Parameter block: The work to be done.
    public init(prioritize priority: SoonerOrLater = .later, block: @escaping () -> Void) {
        job = block
        self.priority = priority
    }
    
    
    /// Cancels a pending run.
    public func cancel() {
        workItem.cancel()
        workItem = DispatchWorkItem { self.job(); self.status = .idle }
        status = .idle
    }
    
    
    /// Schedules a run of the job.
    /// - Parameter delay: How long to wait before running the task.
    public func run(withDelay delay: TimeInterval) {
        
        let comparator: (TimeInterval, TimeInterval) -> Bool
        switch priority {
        case .sooner:
            comparator = (<=)
        case .later:
            comparator = (>=)
        }
        
        switch status {
        case .waiting where comparator(delay, status.timeRemaining):
            cancel()
            fallthrough
        case .idle:
            queue.asyncAfter(deadline: .now() + delay, execute: workItem)
            status = .waiting(for: delay, since: Date())
        default:
            break
        }
    }
    
    
    /// Schedules a run of the job.
    /// - Parameter delay: How long to wait before running the task.
    public func run(withDelay delay: GranularTimeInterval) {
        run(withDelay: delay.timeInterval)
    }
    
    private enum Status {
        var timeRemaining: TimeInterval {
            switch self {
            case let .waiting(for: delay, since: dateStarted):
                return dateStarted.timeIntervalSinceNow + delay
            case .idle:
                return 0
            }
        }
        
        case waiting(for: TimeInterval, since: Date)
        case idle
    }
    
    
    /// Options for how tasks should be prioritized.
    public enum SoonerOrLater {
        case sooner
        case later
    }
}


/// Units for specifying units of time
public enum GranularTimeInterval {
    
    var timeInterval: TimeInterval {
        let multiplier: Double
        let timeValue: Int
        switch self {
        case .weeks(let value):
            multiplier = 604_800
            timeValue = value
        case .days(let value):
            multiplier = 86_400
            timeValue = value
        case .minutes(let value):
            multiplier = 60
            timeValue = value
        case .seconds(let value):
            multiplier = 1
            timeValue = value
        case .milliseconds(let value):
            multiplier = 0.001
            timeValue = value
        case .microseconds(let value):
            multiplier = 0.000001
            timeValue = value
        case .nanoseconds(let value):
            multiplier = 0.000000001
            timeValue = value
        }
        return Double(timeValue) * multiplier
    }
    
    case weeks(Int)
    case days(Int)
    case minutes(Int)
    case seconds(Int)
    case milliseconds(Int)
    case microseconds(Int)
    case nanoseconds(Int)
}
