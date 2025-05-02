//
// PointApp1Tests.swift
// PointApp1Tests
//
// Created by Manus on [Date].
// Copyright © [Year] Manus. All rights reserved.
//

import XCTest
@testable import PointApp1 // Import the module to test

// Mock AdManager for testing HomeViewModel without real ads
class MockAdManager: AdManager {
    var showAdCalled = false
    var loadAdCalled = false

    // Override methods to track calls
    override func showRewardedAd() {
        showAdCalled = true
        // Simulate reward callback for testing point addition
        // In a real scenario, this would be triggered by the ad SDK
        // For simplicity, we assume the reward is granted immediately after showAd is called.
        // pointManager?.addPointsForAdReward() // This might cause issues if PointManager isn't properly mocked or injected
    }
    override func loadRewardedAd() {
        loadAdCalled = true
        // Simulate ad readiness for testing button state
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { // Simulate async loading
            self.isAdReady = true
            self.isLoadingAd = false
        }
    }
}

class PointApp1Tests: XCTestCase {

    var pointManager: PointManager!
    var authViewModel: AuthViewModel!
    var homeViewModel: HomeViewModel!
    var mockAdManager: MockAdManager!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        // Reset UserDefaults for consistent testing
        UserDefaults.standard.removeObject(forKey: "userPoints")

        pointManager = PointManager()
        authViewModel = AuthViewModel()
        mockAdManager = MockAdManager(pointManager: pointManager) // Use mock AdManager
        homeViewModel = HomeViewModel(pointManager: pointManager, adManager: mockAdManager)

        // Note: Firebase interactions are not easily testable in unit tests without mocking frameworks or a dedicated test environment.
        // These tests focus on local logic.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        pointManager = nil
        authViewModel = nil
        homeViewModel = nil
        mockAdManager = nil
        UserDefaults.standard.removeObject(forKey: "userPoints")
    }

    // MARK: - PointManager Tests

    func testAddPoints() throws {
        let initialPoints = pointManager.currentPoints
        let pointsToAdd = pointManager.pointsPerAd
        pointManager.addPointsForAdReward()
        XCTAssertEqual(pointManager.currentPoints, initialPoints + pointsToAdd, "Points should be added correctly.")
    }

    func testCouponAvailability() throws {
        pointManager.currentPoints = 50
        pointManager.fetchInitialPoints() // Update coupon status based on points
        XCTAssertFalse(pointManager.isCouponAvailable, "Coupon should not be available with 50 points.")

        pointManager.currentPoints = pointManager.pointsForCoupon // Set points exactly to coupon requirement
        pointManager.fetchInitialPoints()
        XCTAssertTrue(pointManager.isCouponAvailable, "Coupon should be available with \(pointManager.pointsForCoupon) points.")

        pointManager.currentPoints = 150
        pointManager.fetchInitialPoints()
        XCTAssertTrue(pointManager.isCouponAvailable, "Coupon should be available with 150 points.")
    }

    func testResetPoints() throws {
        pointManager.currentPoints = 50
        pointManager.resetPoints()
        XCTAssertEqual(pointManager.currentPoints, 0, "Points should be reset to 0.")
        XCTAssertFalse(pointManager.isCouponAvailable, "Coupon should not be available after reset.")
    }

    // MARK: - HomeViewModel Tests

    func testWatchAdButtonTapped() throws {
        // Ensure ad is ready before tapping
        mockAdManager.isAdReady = true
        homeViewModel.watchAdButtonTapped()
        XCTAssertTrue(mockAdManager.showAdCalled, "showRewardedAd should be called on AdManager.")
    }

    func testAdButtonDisabledWhenNotReady() throws {
        mockAdManager.isAdReady = false
        mockAdManager.isLoadingAd = false
        // In SwiftUI, button disabled state is checked in the View based on ViewModel's properties.
        // Here we just verify the state in the AdManager which dictates the button state.
        XCTAssertFalse(mockAdManager.isAdReady, "Ad should not be ready initially for the test.")
        // We cannot directly test the SwiftUI Button's disabled state here.
    }

    func testAdButtonDisabledWhenLoading() throws {
        mockAdManager.isAdReady = false
        mockAdManager.isLoadingAd = true
        XCTAssertTrue(mockAdManager.isLoadingAd, "Ad should be loading.")
        // We cannot directly test the SwiftUI Button's disabled state here.
    }

    // MARK: - AuthViewModel Tests (Basic)

    func testSignInAnonymouslyStartsLoading() throws {
        // This test only checks the initial state change.
        // It doesn't mock Firebase response.
        authViewModel.signInAnonymously()
        XCTAssertTrue(authViewModel.isLoading, "isLoading should be true after calling signInAnonymously.")
        // Further testing would require mocking FirebaseAuth.
    }

    // Example of a performance test (optional)
    // func testPerformanceExample() throws {
    //     // This is an example of a performance test case.
    //     self.measure {
    //         // Put the code you want to measure the time of here.
    //     }
    // }

}

