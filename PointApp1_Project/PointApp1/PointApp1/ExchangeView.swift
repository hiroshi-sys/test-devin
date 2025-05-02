//
// ExchangeView.swift
// PointApp1
//
// Created by Manus on [Date].
// Copyright © [Year] Manus. All rights reserved.
//

import SwiftUI

struct ExchangeView: View {
    // PointManagerを監視対象オブジェクトとして受け取る
    @ObservedObject var pointManager: PointManager

    var body: some View {
        VStack(spacing: 20) {
            Text("ポイント交換")
                .font(.largeTitle)
                .padding(.bottom, 30)

            if pointManager.isCouponAvailable {
                // クーポン利用可能な場合
                Text("おめでとうございます！")
                    .font(.title2)
                Text("以下のクーポンが利用可能です。")
                    .padding(.bottom)

                VStack(alignment: .leading, spacing: 10) {
                    Text("クーポンコード:")
                        .font(.headline)
                    Text(pointManager.couponCode)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.blue)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)

                    Text("(\(pointManager.pointsForCoupon)ポイントで交換可能)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding()

                // TODO: クーポン使用済みなどの状態管理を追加する

            } else {
                // クーポン利用不可の場合
                Text("クーポン交換に必要なポイントが足りません。")
                    .foregroundColor(.orange)
                Text("現在のポイント: \(pointManager.currentPoints) P")
                Text("必要ポイント: \(pointManager.pointsForCoupon) P")
                Text("広告を見てポイントを貯めましょう！")
                    .padding(.top)
            }

            Spacer()
        }
        .padding()
        .navigationTitle("クーポン")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// プレビュー用
struct ExchangeView_Previews: PreviewProvider {
    static var previews: some View {
        // クーポン利用可能な場合のプレビュー
        let availableManager = PointManager()
        availableManager.currentPoints = 150 // 十分なポイントを設定
        availableManager.fetchInitialPoints() // isCouponAvailableを更新

        // クーポン利用不可の場合のプレビュー
        let unavailableManager = PointManager()
        unavailableManager.currentPoints = 50 // 不足したポイントを設定
        unavailableManager.fetchInitialPoints() // isCouponAvailableを更新

        NavigationView {
            ExchangeView(pointManager: availableManager)
        }
        .previewDisplayName("Coupon Available")

        NavigationView {
            ExchangeView(pointManager: unavailableManager)
        }
        .previewDisplayName("Coupon Unavailable")
    }
}

