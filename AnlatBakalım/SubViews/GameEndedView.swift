//
//  GameEndedView.swift
//  Anlat Bakalım
//
//  Created by Steven J. Selcuk on 16.01.2021.
//  Copyright © 2021 Steven J. Selcuk. All rights reserved.
//

import ConfettiView
import SwiftUI

struct GameEndedView: View {
    @Binding var redTeamEmoji: String
    @Binding var blueTeamEmoji: String
    @Binding var redTeamName: String
    @Binding var blueTeamName: String

    var teamRed: Int
    var teamBlue: Int
    var isIpad: Bool

    var onPurchase: () -> Void
    var onReStart: () -> Void

    let confettiView = ConfettiView(confetti: [
        .text("🎉"),
        .text("⭐️"),
        .text("🥳"),
        .text("🎊"),
    ])

    var body: some View {
        ZStack {
            confettiView
            VStack(alignment: .center, spacing: 20) {
                Button(action: {
                    self.onReStart()
                }) {
                    HStack(alignment: .center) {
                        if self.teamRed > self.teamBlue {
                            Text("\(self.redTeamEmoji)")
                                .font(.system(size: 40))
                            VStack(alignment: .leading) {
                                Text("ve kazanan \(self.redTeamName)!")
                                    .font(.custom("monogramextended", size: 20))
                                    .fontWeight(.bold)
                                Text("Yeni oyun için buraya dokun")
                                    .font(.custom("monogramextended", size: 16))
                            }

                        } else if self.teamRed == self.teamBlue {
                            Text("🥳")
                                .font(.system(size: 40))
                            VStack(alignment: .leading) {
                                Text("Dostluk kazandı!")
                                    .font(.custom("monogramextended", size: 20))
                                    .fontWeight(.bold)
                                Text("Bir oyun daha?")
                                    .font(.custom("monogramextended", size: 16))
                            }

                        } else {
                            Text("\(self.blueTeamEmoji)")
                                .font(.system(size: 40))
                            VStack(alignment: .leading) {
                                Text("ve kazanan \(self.blueTeamName)!")
                                    .font(.custom("monogramextended", size: 20))
                                    .fontWeight(.bold)
                                Text("Yeni oyun için buraya dokun")
                                    .font(.custom("monogramextended", size: 16))
                            }
                        }
                    }
                    .padding(25)
                    .background(Color("Ebony"))
                    .cornerRadius(80)
                    .frame(width: 300, height: 160)

                }.transition(AnyTransition.asymmetric(insertion: .move(edge: .bottom), removal: .move(edge: .bottom)).combined(with: .opacity))
                    .buttonStyle(NoBGButtonStyleWhite())
                    .frame(maxWidth: 600, maxHeight: 200, alignment: .center)
            }
        }
    }
}
