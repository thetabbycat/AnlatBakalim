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

                Text("\(self.teamBlue)")
                    .foregroundColor(Color("MineShaft"))
                    .font(.custom("monogramextended", size: self.isIpad ? 72 : 48))
                    .fontWeight(.bold)
                    .transition(AnyTransition.asymmetric(insertion: .move(edge: .bottom), removal: .move(edge: .bottom)).combined(with: .opacity))
            }
        }
    }
}
