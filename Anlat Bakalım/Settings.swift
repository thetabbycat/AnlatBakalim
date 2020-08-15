//
//  Settings.swift
//  AnlatBakalim
//
//  Created by Steven J. Selcuk on 10.05.2020.
//  Copyright © 2020 Steven J. Selcuk. All rights reserved.
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

struct Settings: View {
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
        LevelItem(id: 0, name: "Basit", level: 1),
       LevelItem(id: 1, name: "Orta Zorluk", level: 1),
        LevelItem(id: 2, name: "Zor", level: 2),
    ]

    init() {
    }

    var body: some View {
        NavigationView {
            Form {
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

                    Picker(selection: $roundTimeSelection, label: Text("Tur Süresi")) {
                        ForEach(seconds) { sec in
                            Text(sec.name)
                        }
                    }
                    .onReceive([self.roundTimeSelection].publisher.first()) { value in
                        settings.set(value, forKey: "roundTimeSelection")
                        settings.set(self.seconds[value].seconds, forKey: "time")
                    }

                    Stepper("Tur Sayısı: \(self.Game.round)", onIncrement: {
                        if (self.Game.round < 10) {
                            self.Game.round += 1
                        }
                        settings.set(self.Game.round, forKey: "round")

                    }, onDecrement: {
                        if (self.Game.round > 1) {
                            self.Game.round -= 1
                        }
                        settings.set(self.Game.round, forKey: "round")
                    })
                    
                }

                Section(header: Text("Hakkında")) {
                    HStack {
                        Text("Created with ❤️ by").font(.system(size: 14))
                        Spacer()
                        Text("©Tabby Cat, LLC").font(.system(size: 14))
                            .onTapGesture(count: 2) {
                                self.showingEasterEgg = true
                            }
                    }
                }
            }
            .navigationBarTitle("Ayarlar")
        }

        .navigationViewStyle(StackNavigationViewStyle())
        .edgesIgnoringSafeArea(.all)
    }
}
