import XCTest
@testable import DelayedJob
 
@available(macOS 10.12, *)
final class DelayedJobTests: XCTestCase {
    func testDoNotRunBeforeDelay() {
       let jobExpectation = expectation(description: "A job should not run before its delay.")
        jobExpectation.isInverted = true
        let job = DelayedJob { jobExpectation.fulfill() }
        job.run(withDelay: 3)
        waitForExpectations(timeout: 1)
    }

    func testRunAfterDelay() {
        var value = false
        let jobExpectation = expectation(description: "A job should run before its delay.")
        let job = DelayedJob {
            value = true
            jobExpectation.fulfill()
        }
        job.run(withDelay: 1)
        XCTAssertEqual(value, false, "A job should not run before its delay.")
        waitForExpectations(timeout: 2)
        XCTAssertEqual(value, true, "A job should run after its delay.")
    }
    
    func testCancel() {
        let jobExpectation = expectation(description: "A job should not run if it is cancelled.")
        jobExpectation.isInverted = true
        let job = DelayedJob { jobExpectation.fulfill() }
        
        job.run(withDelay: 2)
        job.cancel()
        
        waitForExpectations(timeout: 3)
    }
    
    func testRunAfterCancel() {
        let jobExpectation = expectation(description: "A job be able to be run after it is cancelled.")
        let job = DelayedJob { jobExpectation.fulfill() }
        
        job.run(withDelay: 1)
        job.cancel()
        job.run(withDelay: 1)
        
        waitForExpectations(timeout: 2)
    }
    
    func testJobsObeyLaterPriority() {
        let failureMessage = "If a job's priority is set to `.later`, and a task is run with a delay that is greater than the time remaining in the previously scheduled task, the sooner task should be canceled and the later task scheduled. Conversly if a sooner task is scheduled after, it should be ignored."
        let expectNotToRun = expectation(description: failureMessage + " This task should not have run.")
        expectNotToRun.isInverted = true
        let expectToRun = expectation(description: failureMessage + " Only this task should have run.")

        let job = DelayedJob(prioritize: .later) {
            expectNotToRun.fulfill()
            expectToRun.fulfill()
        }
        
        job.run(withDelay: 1)
        job.run(withDelay: 2)
        job.run(withDelay: 1.5)
        
        wait(for: [expectNotToRun], timeout: 1.75)
        wait(for: [expectToRun], timeout: 2.25)
    }
    
    func testJobsObeySoonerPriority() {
        let failureMessage = "If a job's priority is set to `.sooner`, and a task is run with a delay that is lesser than the time remaining in the previously scheduled task, the later task should be disregarded and the sooner task remain scheduled. Conversly if a sooner task is scheduled after, it should be scheduled and the previous task canceled."
        
        let expectToRun = expectation(description: failureMessage + " Only this task should have run.")
        var timeWaited: TimeInterval = 0
        let timeStarted = Date()
        let job = DelayedJob(prioritize: .sooner) {
            timeWaited = abs(timeStarted.timeIntervalSinceNow)
            expectToRun.fulfill()
        }

        let highDelay = 2.0
        let targetDelay = 1.0
        let mediumDelay = 1.5
        
        job.run(withDelay: highDelay)
        job.run(withDelay: targetDelay)
        job.run(withDelay: mediumDelay)

        wait(for: [expectToRun], timeout: 2.25)
        XCTAssert(timeWaited > targetDelay && timeWaited < mediumDelay, failureMessage)
    }
    
    
    /*
    static var allTests = [
        ("testDoNotRunBeforeDelay", testDoNotRunBeforeDelay),
        ("testRunAfterDelay", testRunAfterDelay )
    ]
    */
}
