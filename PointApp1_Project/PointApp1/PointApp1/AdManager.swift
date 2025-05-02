//
// AdManager.swift
// PointApp1
//
// Created by Manus on [Date].
// Copyright © [Year] Manus. All rights reserved.
//

import Foundation
import GoogleMobileAds
import FirebaseAnalytics // Analytics イベント送信のため
import UIKit // UIViewController を取得するため

class AdManager: NSObject, ObservableObject, GADFullScreenContentDelegate {

    // リワード広告インスタンス
    @Published var rewardedAd: GADRewardedAd?
    // 広告がロード中かを示すフラグ
    @Published var isLoadingAd: Bool = false
    // 広告表示準備完了フラグ
    @Published var isAdReady: Bool = false
    // エラーメッセージ
    @Published var errorMessage: String? = nil

    // ポイント管理マネージャーへの参照
    private weak var pointManager: PointManager?

    // 広告ユニットID (ユーザー指定の値に置き換え)
    private let adUnitID = "ca-app-pub-3940256099942544/1712485313" // テスト用ID。本番用は "ca-app-pub-1234567890123456/1234567"

    init(pointManager: PointManager) {
        self.pointManager = pointManager
        super.init()
        // 初期化時に最初の広告をロード開始
        loadRewardedAd()
    }

    // リワード広告をロードするメソッド
    func loadRewardedAd() {
        guard !isLoadingAd else { return } // ロード中の場合は何もしない
        print("Loading rewarded ad...")
        isLoadingAd = true
        isAdReady = false // ロード開始時に準備完了フラグをリセット
        errorMessage = nil
        rewardedAd = nil // 既存の広告インスタンスをクリア

        let request = GADRequest()
        // 必要に応じてテストデバイスIDを設定 (AppDelegateでも設定可能)
        // GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = [ "ABCD1234EFGH5678" ]

        GADRewardedAd.load(withAdUnitID: adUnitID, request: request) { [weak self] ad, error in
            guard let self = self else { return }
            self.isLoadingAd = false
            if let error = error {
                print("Failed to load rewarded ad with error: \(error.localizedDescription)")
                self.errorMessage = "広告の読み込みに失敗しました。"
                self.rewardedAd = nil
                self.isAdReady = false
                // Analytics イベント送信 (広告ロード失敗)
                Analytics.logEvent("ad_load_failed", parameters: [
                    "ad_unit_id": self.adUnitID as NSObject,
                    "error_message": error.localizedDescription as NSObject,
                    "ad_type": "rewarded" as NSObject
                ])
                return
            }
            print("Rewarded ad loaded successfully.")
            self.rewardedAd = ad
            self.rewardedAd?.fullScreenContentDelegate = self // デリゲートを設定
            self.isAdReady = true
            // Analytics イベント送信 (広告ロード成功)
            Analytics.logEvent("ad_load_success", parameters: [
                "ad_unit_id": self.adUnitID as NSObject,
                "ad_type": "rewarded" as NSObject
            ])
        }
    }

    // リワード広告を表示するメソッド
    func showRewardedAd() {
        guard let ad = rewardedAd, isAdReady else {
            print("Ad wasn't ready to be shown or already shown.")
            // 広告が準備できていない場合は再ロードを試みる
            if !isLoadingAd {
                loadRewardedAd()
            }
            return
        }

        // 広告表示に適したViewControllerを取得
        guard let rootViewController = findKeyWindow()?.rootViewController else {
            print("Could not find root view controller to present ad.")
            errorMessage = "広告表示に失敗しました。"
            return
        }

        print("Showing rewarded ad...")
        // ユーザーが広告を視聴し終えた際の報酬処理クロージャ
        ad.present(fromRootViewController: rootViewController) { [weak self] in
            guard let self = self else { return }
            let reward = ad.adReward
            print("Reward received with currency: \(reward.type), amount \(reward.amount).")
            // ポイントを加算
            self.pointManager?.addPointsForAdReward()
            // Analytics イベント送信 (報酬獲得)
            Analytics.logEvent(AnalyticsEventEarnVirtualCurrency, parameters: [
                AnalyticsParameterVirtualCurrencyName: "points" as NSObject,
                AnalyticsParameterValue: self.pointManager?.pointsPerAd as? NSNumber ?? 0,
                "ad_unit_id": self.adUnitID as NSObject,
                "ad_type": "rewarded" as NSObject
            ])

            // 報酬獲得後、次の広告をロードしておく
            self.isAdReady = false // 表示後は準備完了フラグをリセット
            self.loadRewardedAd()
        }
    }

    // KeyWindowを見つけるヘルパーメソッド
    private func findKeyWindow() -> UIWindow? {
        return UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .compactMap { $0 as? UIWindowScene }
            .first?.windows
            .filter { $0.isKeyWindow }
            .first
    }

    // MARK: - GADFullScreenContentDelegate Methods

    /// Tells the delegate that the ad failed to present full screen content.
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("Ad did fail to present full screen content with error \(error.localizedDescription).")
        errorMessage = "広告の表示に失敗しました。"
        isAdReady = false // 表示失敗したら準備完了フラグをリセット
        // 次の広告をロード
        loadRewardedAd()
        // Analytics イベント送信 (広告表示失敗)
        Analytics.logEvent("ad_present_failed", parameters: [
            "ad_unit_id": adUnitID as NSObject,
            "error_message": error.localizedDescription as NSObject,
            "ad_type": "rewarded" as NSObject
        ])
    }

    /// Tells the delegate that the ad presented full screen content.
    func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Ad did present full screen content.")
        // Analytics イベント送信 (広告表示成功)
        Analytics.logEvent("ad_present_success", parameters: [
            "ad_unit_id": adUnitID as NSObject,
            "ad_type": "rewarded" as NSObject
        ])
    }

    /// Tells the delegate that the ad dismissed full screen content.
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Ad did dismiss full screen content.")
        // ユーザーが広告を閉じた後（報酬獲得有無に関わらず）、次の広告をロード
        // 注意: 報酬獲得前に閉じられた場合、報酬獲得クロージャは呼ばれない
        isAdReady = false // 表示後は準備完了フラグをリセット
        // 報酬獲得クロージャ内でロード済みでなければロード開始
        if rewardedAd == nil && !isLoadingAd {
             loadRewardedAd()
        }
        // Analytics イベント送信 (広告閉じ)
        Analytics.logEvent("ad_dismiss", parameters: [
            "ad_unit_id": adUnitID as NSObject,
            "ad_type": "rewarded" as NSObject
        ])
    }
}

