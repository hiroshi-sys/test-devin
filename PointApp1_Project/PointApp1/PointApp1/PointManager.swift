//
// PointManager.swift
// PointApp1
//
// Created by Manus on [Date].
// Copyright © [Year] Manus. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import FirebaseAnalytics

class PointManager: ObservableObject {

    @Published var currentPoints: Int = 0
    @Published var isCouponAvailable: Bool = false

    private let userDefaultsKey = "userPoints"
    private var db = Firestore.firestore()
    private var userId: String? {
        Auth.auth().currentUser?.uid
    }
    private var userDocumentRef: DocumentReference? {
        guard let userId = userId else { return nil }
        return db.collection("users").document(userId)
    }

    private let pointsPerAd = 10
    private let pointsForCoupon = 100
    let couponCode = "100円割引"

    init() {
        // ログイン状態が変わったらポイントを再取得
        // (AppCoordinatorで認証状態が変わったタイミングで呼ぶのがより堅牢)
        // ここでは初期化時に一度だけ取得を試みる
        fetchInitialPoints()
    }

    // 初期ポイント取得 (UserDefaults -> Firestore)
    func fetchInitialPoints() {
        // まずUserDefaultsから読み込み
        self.currentPoints = UserDefaults.standard.integer(forKey: userDefaultsKey)
        updateCouponStatus()
        print("Loaded points from UserDefaults: \(self.currentPoints)")

        // Firestoreから最新情報を取得して同期
        fetchPointsFromFirestore()
    }

    // ポイント加算処理
    func addPointsForAdReward() {
        let pointsToAdd = pointsPerAd
        let previousPoints = currentPoints
        currentPoints += pointsToAdd
        print("Points added: \(pointsToAdd). New total: \(currentPoints)")

        // ポイントを保存
        savePointsToUserDefaults()
        savePointsToFirestore()
        updateCouponStatus()

        // Firebase Analytics でポイント獲得ログを送信
        Analytics.logEvent("earn_virtual_currency", parameters: [
            AnalyticsParameterVirtualCurrencyName: "points" as NSObject,
            AnalyticsParameterValue: pointsToAdd as NSNumber,
            "previous_points": previousPoints as NSNumber,
            "current_points": currentPoints as NSNumber,
            "trigger": "rewarded_ad" as NSObject
        ])
    }

    // クーポン利用可能かチェック・更新
    private func updateCouponStatus() {
        isCouponAvailable = currentPoints >= pointsForCoupon
    }

    // UserDefaultsにポイントを保存
    private func savePointsToUserDefaults() {
        UserDefaults.standard.set(currentPoints, forKey: userDefaultsKey)
        print("Saved points to UserDefaults: \(currentPoints)")
    }

    // Firestoreにポイントを保存
    private func savePointsToFirestore() {
        guard let userDocRef = userDocumentRef else {
            print("Error: User not logged in, cannot save points to Firestore.")
            return
        }
        // Firestoreにはポイント情報のみを保存（他のユーザー情報も将来的に追加可能）
        userDocRef.setData(["points": currentPoints], merge: true) { error in
            if let error = error {
                print("Error writing points to Firestore: \(error.localizedDescription)")
                // エラー時のリトライや通知処理をここに追加可能
            } else {
                print("Successfully saved points to Firestore: \(self.currentPoints)")
            }
        }
    }

    // Firestoreからポイントを取得
    func fetchPointsFromFirestore() {
        guard let userDocRef = userDocumentRef else {
            print("Error: User not logged in, cannot fetch points from Firestore.")
            // ログインしていない場合、UserDefaultsの値を使用し続ける
            return
        }

        userDocRef.getDocument { [weak self] (document, error) in
            guard let self = self else { return }
            if let document = document, document.exists {
                if let points = document.data()?["points"] as? Int {
                    // Firestoreの値がUserDefaultsと異なる場合、Firestoreを正とする
                    if points != self.currentPoints {
                        print("Firestore points (\(points)) differ from UserDefaults (\(self.currentPoints)). Updating.")
                        self.currentPoints = points
                        self.savePointsToUserDefaults() // UserDefaultsも更新
                        self.updateCouponStatus()
                    }
                    print("Successfully fetched points from Firestore: \(points)")
                } else {
                    // Firestoreにポイントデータがない場合（初回ログインなど）
                    print("No points data found in Firestore for user. Using UserDefaults value: \(self.currentPoints)")
                    // 現在のポイント（UserDefaultsから読み込んだ値）をFirestoreに保存
                    self.savePointsToFirestore()
                }
            } else {
                if let error = error {
                    print("Error fetching points from Firestore: \(error.localizedDescription)")
                } else {
                    // ドキュメントが存在しない場合（初回ログインなど）
                    print("User document does not exist in Firestore. Using UserDefaults value: \(self.currentPoints)")
                    // 現在のポイント（UserDefaultsから読み込んだ値）をFirestoreに保存
                    self.savePointsToFirestore()
                }
            }
        }
    }

    // ポイントをリセットする（デバッグ用など）
    func resetPoints() {
        currentPoints = 0
        savePointsToUserDefaults()
        savePointsToFirestore()
        updateCouponStatus()
        print("Points reset to 0.")
        Analytics.logEvent("reset_points", parameters: nil)
    }
}

