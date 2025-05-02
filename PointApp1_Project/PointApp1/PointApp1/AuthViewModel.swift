//
// AuthViewModel.swift
// PointApp1
//
// Created by Manus on [Date].
// Copyright © [Year] Manus. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseAnalytics // Analytics イベント送信のため

class AuthViewModel: ObservableObject {
    @Published var errorMessage: String? = nil
    @Published var isLoading: Bool = false

    // 匿名サインインを実行するメソッド
    func signInAnonymously() {
        isLoading = true
        errorMessage = nil

        Auth.auth().signInAnonymously { [weak self] (authResult, error) in
            guard let self = self else { return }
            self.isLoading = false

            if let error = error {
                // サインイン失敗時の処理
                print("Error signing in anonymously: \(error.localizedDescription)")
                self.errorMessage = "サインインに失敗しました。通信環境をご確認ください。"
                // Analytics イベント送信 (失敗)
                Analytics.logEvent("login_anonymous_failed", parameters: [
                    "error_message": error.localizedDescription as NSObject
                ])
                return
            }

            // サインイン成功時の処理
            if let user = authResult?.user {
                print("Successfully signed in anonymously with user ID: \(user.uid)")
                // Coordinatorが認証状態の変化を検知して画面遷移するため、ここでは特別な処理は不要
                // Analytics イベント送信 (成功)
                Analytics.logEvent(AnalyticsEventLogin, parameters: [
                    AnalyticsParameterMethod: "anonymous" as NSObject,
                    "user_id": user.uid as NSObject
                ])
            } else {
                // 通常ここには到達しないはずだが、念のためエラー処理
                print("Auth result or user is nil after successful anonymous sign-in.")
                self.errorMessage = "予期せぬエラーが発生しました。"
                Analytics.logEvent("login_anonymous_failed", parameters: [
                    "error_message": "Auth result or user is nil" as NSObject
                ])
            }
        }
    }
}

