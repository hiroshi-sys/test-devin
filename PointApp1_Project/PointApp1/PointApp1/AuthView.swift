//
// AuthView.swift
// PointApp1
//
// Created by Manus on [Date].
// Copyright © [Year] Manus. All rights reserved.
//

import SwiftUI

struct AuthView: View {
    // ViewModelを監視対象オブジェクトとして生成
    @StateObject private var viewModel = AuthViewModel()
    // AppCoordinatorを環境オブジェクトとして受け取る (画面遷移はCoordinatorが担当)
    @EnvironmentObject var appCoordinator: AppCoordinator

    var body: some View {
        VStack(spacing: 20) {
            Text("ようこそ！")
                .font(.largeTitle)

            Text("ポイントを貯めるにはサインインが必要です。")
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            // 匿名サインインボタン
            Button("匿名でサインイン") {
                viewModel.signInAnonymously()
            }
            .padding()
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.isLoading) // ローディング中は無効化

            // ローディングインジケーター
            if viewModel.isLoading {
                ProgressView()
            }

            // エラーメッセージ表示
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding(.top)
            }
        }
        .padding()
    }
}

// プレビュー用
struct AuthView_Previews: PreviewProvider {
    static var previews: some View {
        AuthView()
            .environmentObject(AppCoordinator()) // プレビュー用にダミーのCoordinatorを提供
    }
}

