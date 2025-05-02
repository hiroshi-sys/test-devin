//
// SettingsView.swift
// PointApp1
//
// Created by Manus on [Date].
// Copyright © [Year] Manus. All rights reserved.
//

import SwiftUI
import FirebaseAuth

struct SettingsView: View {
    // AppCoordinatorを環境オブジェクトとして受け取る (サインアウト処理のため)
    @EnvironmentObject var appCoordinator: AppCoordinator
    // PointManagerのインスタンス（ポイントリセット用、本来はViewModel経由が望ましい）
    // TODO: ViewModel経由での依存性注入に修正する
    @StateObject private var pointManager = PointManager()

    @State private var showingSignOutAlert = false
    @State private var showingResetPointsAlert = false

    var body: some View {
        List {
            // アカウント情報セクション (今はダミー)
            Section(header: Text("アカウント")) {
                HStack {
                    Text("ユーザーID")
                    Spacer()
                    // 匿名ユーザーIDを表示 (取得できなければ "-")
                    Text(Auth.auth().currentUser?.uid ?? "-")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }

            // ポイント管理セクション
            Section(header: Text("ポイント管理")) {
                Button("ポイントをリセット (デバッグ用)") {
                    showingResetPointsAlert = true
                }
                .foregroundColor(.orange)
            }

            // アプリ情報セクション (今はダミー)
            Section(header: Text("アプリについて")) {
                HStack {
                    Text("バージョン")
                    Spacer()
                    Text("1.0.0") // TODO: バンドルバージョンから取得する
                }
                // ライセンス表示や利用規約へのリンクなどを追加可能
            }

            // サインアウトボタン
            Section {
                Button("サインアウト") {
                    showingSignOutAlert = true
                }
                .foregroundColor(.red)
            }
        }
        .navigationTitle("設定")
        .navigationBarTitleDisplayMode(.inline)
        .alert("サインアウト", isPresented: $showingSignOutAlert) {
            Button("キャンセル", role: .cancel) { }
            Button("サインアウト", role: .destructive) {
                signOut()
            }
        } message: {
            Text("サインアウトしますか？")
        }
        .alert("ポイントリセット", isPresented: $showingResetPointsAlert) {
            Button("キャンセル", role: .cancel) { }
            Button("リセット実行", role: .destructive) {
                pointManager.resetPoints()
            }
        } message: {
            Text("現在のポイントが0になります。この操作は元に戻せません。実行しますか？ (デバッグ用)")
        }
    }

    // サインアウト処理
    func signOut() {
        do {
            try Auth.auth().signOut()
            print("Successfully signed out.")
            // AppCoordinatorが認証状態の変化を検知して画面遷移する
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
            // エラーメッセージをユーザーに表示する処理を追加可能
        }
    }
}

// プレビュー用
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SettingsView()
                .environmentObject(AppCoordinator()) // プレビュー用にダミーのCoordinatorを提供
        }
    }
}

