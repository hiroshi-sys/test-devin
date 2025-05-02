//
// HomeView.swift
// PointApp1
//
// Created by Manus on [Date].
// Copyright © [Year] Manus. All rights reserved.
//

import SwiftUI

struct HomeView: View {
    // AppCoordinatorからPointManagerとAdManagerを取得 (DI)
    // 本来はViewModel経由で渡すが、簡略化のため直接生成・参照
    // TODO: ViewModel経由での依存性注入に修正する
    @StateObject private var pointManager = PointManager()
    @StateObject private var adManager: AdManager
    @StateObject private var viewModel: HomeViewModel

    // AppCoordinatorを環境オブジェクトとして受け取る
    @EnvironmentObject var appCoordinator: AppCoordinator

    // AdManagerの初期化をHomeViewのinitで行う
    init() {
        let pm = PointManager()
        let am = AdManager(pointManager: pm)
        _pointManager = StateObject(wrappedValue: pm)
        _adManager = StateObject(wrappedValue: am)
        _viewModel = StateObject(wrappedValue: HomeViewModel(pointManager: pm, adManager: am))
    }

    var body: some View {
        NavigationView { // 画面遷移のためにNavigationViewを使用
            VStack(spacing: 30) {
                // ポイント表示エリア
                VStack {
                    Text("現在のポイント")
                        .font(.headline)
                    Text("\(viewModel.pointManager.currentPoints) P")
                        .font(.system(size: 60, weight: .bold))
                }
                .padding(.top, 50)

                // 広告視聴ボタン
                Button {
                    viewModel.watchAdButtonTapped()
                } label: {
                    HStack {
                        Image(systemName: "play.tv.fill")
                        Text(viewModel.adManager.isLoadingAd ? "広告準備中..." : "広告を見てポイントGET")
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(!viewModel.adManager.isAdReady || viewModel.adManager.isLoadingAd) // 広告準備中またはロード中は無効
                .padding(.horizontal)

                // エラーメッセージ表示 (広告関連)
                if let errorMessage = viewModel.adManager.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding(.horizontal)
                }

                Spacer() // スペースを空ける

                // クーポン交換画面へのナビゲーションリンク
                NavigationLink(destination: ExchangeView(pointManager: viewModel.pointManager), isActive: $viewModel.showExchangeView) {
                    // NavigationLink自体は非表示にし、ボタンで遷移をトリガー
                    EmptyView()
                }
                Button {
                    viewModel.showExchangeView = true
                } label: {
                    HStack {
                        Image(systemName: "giftcard.fill")
                        Text("ポイント交換")
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .padding(.horizontal)

                // 設定画面へのナビゲーションリンク (今はダミー)
                NavigationLink(destination: SettingsView(), isActive: $viewModel.showSettingsView) {
                    EmptyView()
                }

            }
            .navigationTitle("ホーム")
            .navigationBarItems(trailing: 
                HStack {
                    // 更新ボタン
                    Button {
                        viewModel.refreshPoints()
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                    // 設定ボタン
                    Button {
                        viewModel.showSettingsView = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                    }
                }
            )
            .onAppear {
                // 画面表示時にポイントを再取得 (Firestoreとの同期)
                viewModel.refreshPoints()
                // 広告が準備できていなければロードを試みる
                if !viewModel.adManager.isAdReady && !viewModel.adManager.isLoadingAd {
                    viewModel.adManager.loadRewardedAd()
                }
            }
        }
        // NavigationViewの外側で環境オブジェクトを設定するのが一般的
        // .environmentObject(appCoordinator) // 親Viewから渡される想定
    }
}

// プレビュー用
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        // プレビュー用にダミーのCoordinatorとViewModelを提供
        let coordinator = AppCoordinator()
        // HomeView内でViewModel等が初期化されるため、ここではCoordinatorのみ渡す
        HomeView()
            .environmentObject(coordinator)
    }
}

