//
// AppCoordinator.swift
// PointApp1
//
// Created by Manus on [Date].
// Copyright © [Year] Manus. All rights reserved.
//

import SwiftUI
import FirebaseAuth

// アプリ全体のナビゲーションと状態を管理するCoordinator
class AppCoordinator: ObservableObject {

    // 認証状態を管理。変更があればViewが更新されるように@Publishedを付与
    @Published var isLoggedIn: Bool = false

    // Firebase Authの状態変化リスナーハンドル
    private var authStateHandler: AuthStateDidChangeListenerHandle?

    init() {
        // アプリ起動時に認証状態の監視を開始
        listenToAuthState()
    }

    deinit {
        // インスタンス破棄時にリスナーを解除
        if let handle = authStateHandler {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }

    // 認証状態を監視するメソッド
    func listenToAuthState() {
        authStateHandler = Auth.auth().addStateDidChangeListener { [weak self] (auth, user) in
            guard let self = self else { return }
            // ユーザーオブジェクトが存在すればログイン済みと判断
            self.isLoggedIn = (user != nil)
            print("Auth state changed: isLoggedIn = \(self.isLoggedIn)")
        }
    }

    // アプリの開始点を定義。認証状態に応じて表示するビューを切り替える
    @ViewBuilder
    func start() -> some View {
        if isLoggedIn {
            // ログイン済みならホーム画面を表示
            HomeView()
                .environmentObject(self) // Coordinatorを子ビューに渡す
        } else {
            // 未ログインなら認証画面を表示
            AuthView()
                .environmentObject(self) // Coordinatorを子ビューに渡す
        }
    }

    // --- 画面遷移メソッド (将来の拡張用) ---
    // 例: ホーム画面を表示するメソッド (現在はstart()内で直接分岐)
    // func showHome() { ... }

    // 例: 認証画面を表示するメソッド (現在はstart()内で直接分岐)
    // func showAuth() { ... }

    // 例: 設定画面を表示するメソッド
    // func showSettings() { ... }

    // 例: ポイント交換画面を表示するメソッド
    // func showExchange() { ... }
}

