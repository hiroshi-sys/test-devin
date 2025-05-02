//
// HomeViewModel.swift
// PointApp1
//
// Created by Manus on [Date].
// Copyright © [Year] Manus. All rights reserved.
//

import Foundation
import Combine

class HomeViewModel: ObservableObject {
    // PointManagerとAdManagerへの参照（DI: Dependency Injection）
    @Published var pointManager: PointManager
    @Published var adManager: AdManager

    // ナビゲーション用のフラグ
    @Published var showExchangeView = false
    @Published var showSettingsView = false

    private var cancellables = Set<AnyCancellable>()

    init(pointManager: PointManager, adManager: AdManager) {
        self.pointManager = pointManager
        self.adManager = adManager

        // PointManagerのポイント変更を監視 (必要に応じてUI更新)
        pointManager.$currentPoints
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.objectWillChange.send() // Viewに変更を通知
            }
            .store(in: &cancellables)

        // AdManagerの状態変更を監視 (広告ボタンの有効/無効など)
        adManager.$isAdReady
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
        adManager.$isLoadingAd
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }

    // 広告視聴ボタンのアクション
    func watchAdButtonTapped() {
        adManager.showRewardedAd()
    }

    // ポイント履歴をFirestoreから再取得するアクション
    func refreshPoints() {
        pointManager.fetchPointsFromFirestore()
    }
}

