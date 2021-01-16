//
//  HeaderView.swift
//  Anlat Bakalım
//
//  Created by Steven J. Selcuk on 16.01.2021.
//  Copyright © 2021 Steven J. Selcuk. All rights reserved.
//

import SwiftUI

struct HeaderView: View {
    @Binding var redTeamEmoji: String
    @Binding var blueTeamEmoji: String
    @Binding var redTeamName: String
    @Binding var blueTeamName: String
    var teamRed: Int
    var teamBlue: Int
    var isPremium: Bool
    var isIpad: Bool
    var round: Int
    var timeRemaining: Int

    func textForPlaybackTime(time: TimeInterval) -> String {
        if !time.isNormal {
            return "00:00"
        }
        let hours = Int(floor(time / 3600))
        let minutes = Int(floor((time / 60).truncatingRemainder(dividingBy: 60)))
        let seconds = Int(floor(time.truncatingRemainder(dividingBy: 60)))
        let minutesAndSeconds = NSString(format: "%02d:%02d", minutes, seconds) as String
        if hours > 0 {
            return NSString(format: "%02d:%@", hours, minutesAndSeconds) as String
        } else {
            return minutesAndSeconds
        }
    }

    var body: some View {
        HStack {
            VStack(spacing: 1) {
                Text(self.redTeamEmoji)
                    .font(Font.system(size: 48))
                    .frame(maxWidth: 64, maxHeight: 64, alignment: .center)
                    .transition(AnyTransition.asymmetric(insertion: .move(edge: .bottom), removal: .move(edge: .bottom)).combined(with: .opacity))
                    //   .if(self.Game.currentTeam == "red") { $0.multicolorGlow(rotation: self.Game.teamRed) }
                    .modifier(ShakeEffect(shakes: self.teamRed * 2))
                   .if(self.isPremium) { $0.contextMenu {
                        Button(action: {
                            self.redTeamEmoji = "🥑"
                            self.redTeamName = "Avokadolar"
                        }) {
                            Text("🥑 Avokadolar")
                        }
                        Button(action: {
                            self.redTeamEmoji = "🥜"
                            self.redTeamName = "Fıstıklar"
                        }) {
                            Text("🥜 Fıstıklar")
                        }
                        Button(action: {
                            self.redTeamEmoji = "🌼"
                            self.redTeamName = "Çiçekler"
                        }) {
                            Text("🌼 Çiçekler")
                        }
                        Button(action: {
                            self.redTeamEmoji = "🐈"
                            self.redTeamName = "Kedi Kuyruğu"
                        }) {
                            Text("🐈 Kedi Kuyruğu")
                        }
                    } }

                Text("\(self.teamRed)")
                    .foregroundColor(Color("MineShaft"))
                    .font(.custom("monogramextended", size: self.isIpad ? 72 : 48))
                    .fontWeight(.bold)
                    .transition(AnyTransition.asymmetric(insertion: .move(edge: .bottom), removal: .move(edge: .bottom)).combined(with: .opacity))
            }

            VStack {
                Text(self.round > 1 ? "Kalan tur: \(self.round)" : "⚠️ Son tur")
                    .foregroundColor(Color("MineShaft"))
                    .font(.custom("monogramextended", size: self.isIpad ? 36 : 28))

                TimerRing(fontSize: self.isIpad ? 96 : 48, remainingTime: String(textForPlaybackTime(time: TimeInterval(self.timeRemaining))))

            }.padding(.all)
                .transition(AnyTransition.asymmetric(insertion: .move(edge: .bottom), removal: .move(edge: .bottom)).combined(with: .opacity))

            VStack(spacing: 1) {
                Text(self.blueTeamEmoji)
                    .font(Font.system(size: 48))
                    .frame(maxWidth: 64, maxHeight: 64, alignment: .center)
                    .transition(AnyTransition.asymmetric(insertion: .move(edge: .bottom), removal: .move(edge: .bottom)).combined(with: .opacity))
                    .modifier(ShakeEffect(shakes: self.teamBlue * 2))
                    //     .if(self.Game.currentTeam == "blue") { $0.multicolorGlow(rotation: self.Game.teamBlue) }
                    .if(self.isPremium) { $0.contextMenu {
                        Button(action: {
                            self.blueTeamEmoji = "🚀"
                            self.blueTeamName = "Roket Takımı"
                        }) {
                            Text("🚀 Roket Takımı")
                        }
                        Button(action: {
                            self.blueTeamEmoji = "🐛"
                            self.blueTeamName = "Böcekler"
                        }) {
                            Text("🐛 Böcekler")
                        }
                        Button(action: {
                            self.blueTeamEmoji = "☠️"
                            self.blueTeamName = "Killers"
                        }) {
                            Text("☠️ Killers")
                        }
                        Button(action: {
                            self.blueTeamEmoji = "🦮"
                            self.blueTeamName = "Köpek Burnu"
                        }) {
                            Text("🦮 Köpek Burnu")
                        }
                    }
                    }

                Text("\(self.teamBlue)")
                    .foregroundColor(Color("MineShaft"))
                    .font(.custom("monogramextended", size: self.isIpad ? 72 : 48))
                    .fontWeight(.bold)
                    .transition(AnyTransition.asymmetric(insertion: .move(edge: .bottom), removal: .move(edge: .bottom)).combined(with: .opacity))
            }
        }
    }
}
