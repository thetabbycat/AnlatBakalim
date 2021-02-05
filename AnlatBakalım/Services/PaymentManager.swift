//
//  PaymentManager.swift
//  Anlat Bakalım
//
//  Created by Steven J. Selcuk on 2.12.2020.
//  Copyright © 2020 Steven J. Selcuk. All rights reserved.
//

import Foundation
import Purchases
import SwiftUI

public class SubscriptionManager: ObservableObject {
    public static let shared = SubscriptionManager()

    @Published public var monthlySubscription: Purchases.Package?
    @Published public var yearlySubscription: Purchases.Package?
    @Published public var lifetime: Purchases.Package?
    @Published public var inPaymentProgress = false
    @Published public var subscriptionStatus: Bool = UserDefaults.standard.optionalBool(forKey: "isSubscribed") ?? false

    @ObservedObject var fetcher = Fetcher()
    @ObservedObject var Game = GameManager()

    let level = UserDefaults.standard.optionalInt(forKey: "level") ?? 1

    init() {
        Purchases.configure(withAPIKey: "KxxHEZtDNXaVVeFoTFutGgKEcFhiNQlx")
        Purchases.shared.offerings { offerings, _ in
            self.monthlySubscription = offerings?.current?.monthly
            self.lifetime = offerings?.current?.lifetime
            self.yearlySubscription = offerings?.current?.annual
        }
        refreshSubscription()
    }

    public func purchase(source: String, product: Purchases.Package) {
        guard !inPaymentProgress else { return }
        inPaymentProgress = true
        Purchases.shared.purchasePackage(product) { _, info, _, _ in
            self.processInfo(info: info)
        }
    }

    public func refreshSubscription() {
        Purchases.shared.purchaserInfo { info, _ in
            self.processInfo(info: info)
        }
    }

    public func restorePurchase() {
        Purchases.shared.restoreTransactions { info, _ in
            self.processInfo(info: info)
        }
    }

    public func buttonAction(purchase: Purchases.Package) {
        self.purchase(source: "Settings",
                      product: purchase)
    }

    private func processInfo(info: Purchases.PurchaserInfo?) {
        if info?.entitlements.all["Daha fazla kelime"]?.isActive == true {
            subscriptionStatus = true
            settings.set(true, forKey: "isSubscribed")
            fetcher.getPremiumWords()
            fetcher.words = fetcher.fetchLocalUsers().filter { $0.level == level }.shuffled()
            print("sold")

        } else {
            settings.set(false, forKey: "isSubscribed")
            subscriptionStatus = false
            fetcher.getFreeWords()
            fetcher.words = fetcher.fetchLocalUsers().filter { $0.level == level }
            print("not sold")
        }
        inPaymentProgress = false
    }
}
