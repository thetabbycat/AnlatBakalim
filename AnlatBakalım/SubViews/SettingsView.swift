//
//  SettingsView.swift
//  Anlat Bakalım
//
//  Created by Steven J. Selcuk on 16.01.2021.
//  Copyright © 2021 Steven J. Selcuk. All rights reserved.
//

import Purchases
import SwiftUI

struct TimeItem: Identifiable {
    let id: Int
    let name: String
    let seconds: Int
}

struct LevelItem: Identifiable {
    let id: Int
    let name: String
    let level: Int
}

struct SettingsButton: View {
    var onTap: () -> Void
    var isIpad: Bool
    var body: some View {
        Button(action: {
            self.onTap()
        }) {
            HStack {
                Image("Settings")
                    .antialiased(true)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: isIpad ? 64 : 48, maxHeight: isIpad ? 64 : 48, alignment: .center)
            }
        }
        .buttonStyle(MyButtonStyle())
        .offset(x: self.isIpad ? screen.width / 2 - 70 : screen.width / 2 - 50, y: -(screen.height / 2 - 80))
    }
}

struct SettingsView: View {

    @State var roundTimeSelection = UserDefaults.standard.optionalInt(forKey: "roundTimeSelection") ?? 1
    @State var levelSelection = UserDefaults.standard.optionalInt(forKey: "levelSelection") ?? 0
    @State var roundTime = UserDefaults.standard.integer(forKey: "time")
    @State var roundCount = UserDefaults.standard.optionalInt(forKey: "round") ?? 5

    @ObservedObject var Game = GameManager()

    @ObservedObject var fetcher = Fetcher()

    @State private var backgroundColor = Color.white

    @State private var showingEasterEgg = false
    @State private var needVersionUpdated = true

    var seconds = [
        TimeItem(id: 0, name: "1 Dakika", seconds: 60),
        TimeItem(id: 1, name: "3 Dakika", seconds: 180),
        TimeItem(id: 2, name: "5 Dakika", seconds: 300),
        // TimeItem(id: 3, name: "10 Saniye", seconds: 10),
    ]

    var levels = [
        LevelItem(id: 0, name: "Kolay", level: 1),
        LevelItem(id: 1, name: "Orta Zorluk", level: 2),
        LevelItem(id: 2, name: "Zor", level: 3),
    ]


    var body: some View {
        NavigationView {
            Form {
                
                /**
                 if SubscriptionManager().subscriptionStatus == false {
                 Section(header: Text("Premium")) {
                 HStack {
                 HStack(alignment: .center) {
                 Text("🔒")
                 .font(.system(size: 40))
                 VStack(alignment: .leading) {
                 Text("Zaten premium kullanıcı mısın?")
                 .font(.custom("monogramextended", size: 20))
                 .fontWeight(.bold)
                 Text("Geri yüklemek için buraya dokun")
                 .font(.custom("monogramextended", size: 16))
                 }
                 }
                 }
                 .onTapGesture {
                 
                 DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                 self.paymentManager.objectWillChange.send()
                 self.paymentManager.restorePurchase()
                 }
                 
                 
                 
                 
                 }
                 }
                 }
                 
                 */


                Section(header: Text("Oyun Ayarları")) {
                    Picker(selection: $levelSelection, label: Text("Zorluk seviyesi")) {
                        ForEach(levels) { lev in
                            Text(lev.name)
                        }
                    }
                    .onReceive([self.levelSelection].publisher.first()) { value in
                        settings.set(value, forKey: "levelSelection")
                        settings.set(self.levels[value].level, forKey: "level")
                    }
                    .foregroundColor(Color("Text"))
                    .font(.custom("Silka Regular", size: 14))

                    Picker(selection: $roundTimeSelection, label: Text("Tur Süresi")) {
                        ForEach(seconds) { sec in
                            Text(sec.name)
                        }
                    }
                    .onReceive([self.roundTimeSelection].publisher.first()) { value in
                        settings.set(value, forKey: "roundTimeSelection")
                        settings.set(self.seconds[value].seconds, forKey: "time")
                    }
                    .foregroundColor(Color("Text"))
                    .font(.custom("Silka Regular", size: 14))

                    Stepper("Tur Sayısı: \(self.Game.round)", onIncrement: {
                        if self.Game.round < 10 {
                            self.Game.round += 1
                        }
                        settings.set(self.Game.round, forKey: "round")

                    }, onDecrement: {
                        if self.Game.round > 1 {
                            self.Game.round -= 1
                        }
                        settings.set(self.Game.round, forKey: "round")
                    })
                        .foregroundColor(Color("Text"))
                        .font(.custom("Silka Regular", size: 14))
                }

                /**

                 Section(header: Text("Yorum yap")) {
                     HStack {
                         Text("Anlat Bakalım'ı beğendin mi?")
                             .foregroundColor(Color("Text"))
                             .font(.custom("Silka Regular", size: 14))
                         Spacer()
                         Image(systemName: "pencil.and.ellipsis.rectangle")
                     }.onTapGesture {
                         self.requestReviewManually()
                     }
                 } */

                Section(header: Text("Hakkında")) {
                    HStack {
                        Text("Bizi takip et @tabbycatllc")
                            .foregroundColor(Color("Text"))
                            .font(.custom("Silka Regular", size: 14))
                        Spacer()
                        Text("© Tabby Cat, LLC")
                            .foregroundColor(Color("Text"))
                            .font(.custom("Silka Regular", size: 14))
                    }
                    .onTapGesture {
                        self.showingEasterEgg = true
                        let screenName = "tabbycatllc"
                        let appURL = URL(string: "twitter://user?screen_name=\(screenName)")!
                        let webURL = URL(string: "https://twitter.com/\(screenName)")!

                        if UIApplication.shared.canOpenURL(appURL as URL) {
                            if #available(iOS 10.0, *) {
                                UIApplication.shared.open(appURL)
                            } else {
                                UIApplication.shared.openURL(appURL)
                            }
                        } else {
                            if #available(iOS 10.0, *) {
                                UIApplication.shared.open(webURL)
                            } else {
                                UIApplication.shared.openURL(webURL)
                            }
                        }
                    }
                }
            }
            .navigationBarTitle("Ayarlar")
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .edgesIgnoringSafeArea(.all)
    }

    func requestReviewManually() {
        guard let writeReviewURL = URL(string: "https://apps.apple.com/app/idXXXXXXXXXX?action=write-review")
        else { fatalError("Expected a valid URL") }
        UIApplication.shared.open(writeReviewURL, options: [:], completionHandler: nil)
    }
}
