//
// PointApp1App.swift
// PointApp1
//
// Created by Manus on [Date].
// Copyright © [Year] Manus. All rights reserved.
//

import SwiftUI
import Firebase
import GoogleMobileAds // AdMob初期化のため

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    // Firebase初期化
    FirebaseApp.configure()

    // Google Mobile Ads SDKの初期化
    GADMobileAds.sharedInstance().start(completionHandler: nil)

    // テストデバイスIDの設定 (任意)
    // GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = [ "ABCD1234EFGH5678" ] // ユーザー指定のIDに置き換え

    return true
  }
}

@main
struct PointApp1App: App {
    // Firebase初期化のためにAppDelegateを登録
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    // アプリ全体のナビゲーションと状態を管理するCoordinator
    @StateObject var appCoordinator = AppCoordinator()

    var body: some Scene {
        WindowGroup {
            // Coordinatorが提供する初期ビューを表示
            appCoordinator.start()
                .environmentObject(appCoordinator) // Coordinatorを環境オブジェクトとして子ビューに渡す
        }
    }
}

