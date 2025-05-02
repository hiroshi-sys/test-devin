// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PointApp1",
    platforms: [
        .iOS(.v11)
    ],
    products: [
        .library(
            name: "PointApp1",
            targets: ["PointApp1"]),
    ],
    dependencies: [
        // Firebase SDKs
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", from: "10.0.0"),
        // Google Mobile Ads SDK
        .package(url: "https://github.com/googleads/swift-package-manager-google-mobile-ads.git", from: "11.0.0")
    ],
    targets: [
        .target(
            name: "PointApp1",
            dependencies: [
                .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
                .product(name: "FirebaseFirestore", package: "firebase-ios-sdk"),
                .product(name: "FirebaseAnalytics", package: "firebase-ios-sdk"),
                .product(name: "GoogleMobileAds", package: "swift-package-manager-google-mobile-ads")
            ],
            path: "PointApp1", // Specify the path to the source files
            resources: [
                // Add resource files here if needed, e.g., .process("Resources")
                // Note: GoogleService-Info.plist is typically added directly to the Xcode project, not via SPM resources.
            ]
        ),
        .testTarget(
            name: "PointApp1Tests",
            dependencies: ["PointApp1"],
            path: "Tests" // Specify the path to the test files
        ),
    ]
)

