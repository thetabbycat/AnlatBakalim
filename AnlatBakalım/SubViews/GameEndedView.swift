//
//  GameEndedView.swift
//  Anlat Bakalım
//
//  Created by Steven J. Selcuk on 16.01.2021.
//  Copyright © 2021 Steven J. Selcuk. All rights reserved.
//

import SwiftUI
import ConfettiView

struct GameEndedView: View {
    @Binding var redTeamEmoji: String
    @Binding var blueTeamEmoji: String
    @Binding var redTeamName: String
    @Binding var blueTeamName: String
  
    
    var teamRed: Int
    var teamBlue: Int
    var isPremium: Bool
    var isIpad:  Bool
    
    var onPurchase: () -> Void
    var onReStart: () -> Void
    
    let confettiView = ConfettiView(confetti: [
        .text("🎉"),
        .text("⭐️"),
        .text("🥳"),
        .text("🥳"),
    ])
    
    
    var body: some View {
        confettiView
        VStack(alignment: .leading, spacing: 20) {
            if self.isPremium == false {
                if self.teamRed > self.teamBlue {
                    VStack {
                        Text("Tebrikler!")
                            .foregroundColor(.black)
                            .font(.custom("Kalam Bold", size: self.isIpad ? 96 : 32))
                        
                        Text("\(self.redTeamEmoji) \(self.redTeamName)")
                            .foregroundColor(.black)
                            .font(.custom("Kalam Bold", size: self.isIpad ? 96 : 32))
                    }
                    
                } else if self.teamRed == self.teamBlue {
                    Text("Kazanan yok 🤷‍♂️")
                        .foregroundColor(.black)
                        .font(.custom("Kalam Bold", size: self.isIpad ? 96 : 32))
                } else {
                    VStack {
                        Text("Tebrikler")
                            .foregroundColor(.black)
                            .font(.custom("Kalam Bold", size: self.isIpad ? 96 : 32))
                        Text("\(self.blueTeamEmoji) \(self.blueTeamName)")
                            .foregroundColor(.black)
                            .font(.custom("Kalam Bold", size: self.isIpad ? 96 : 32))
                        confettiView
                    }
                }
                
                Button(action: {
                    self.onPurchase()
                }) {
                    HStack(alignment: .center) {
                        Text("🥳")
                            .font(.system(size: 40))
                        VStack(alignment: .leading) {
                            Text("Daha fazla eğlence!")
                                .font(.custom("monogramextended", size: 20))
                                .fontWeight(.bold)
                            Text("Her hafta güncellenen +1500 yeni kelime...\nSatın almak için dokun.")
                                .font(.custom("monogramextended", size: 16))
                        }
                    }
                    .padding(25)
                    .background(Color("Ebony"))
                    .cornerRadius(80)
                    .frame(width: 300, height: 160)
                }
                .transition(AnyTransition.asymmetric(insertion: .move(edge: .bottom), removal: .move(edge: .bottom)).combined(with: .opacity))
                .buttonStyle(NoBGButtonStyle())
                .frame(maxWidth: 600, maxHeight: 200, alignment: .center)
                
            } else {
                Button(action: {
                    self.onReStart()
                }) {
                    HStack(alignment: .center) {
                        if self.teamRed > self.teamBlue {
                            Text("\(self.redTeamEmoji)")
                                .font(.system(size: 40))
                            VStack(alignment: .leading) {
                                Text("Tebrikler!  \(self.redTeamName)")
                                    .font(.custom("monogramextended", size: 20))
                                    .fontWeight(.bold)
                                Text("Yeni oyun için dokun")
                                    .font(.custom("monogramextended", size: 16))
                            }
                            
                        } else if self.teamRed == self.teamBlue {
                            Text("🥳")
                                .font(.system(size: 40))
                            VStack(alignment: .leading) {
                                Text("Beraberlik! Her iki takımı kutlarız")
                                    .font(.custom("monogramextended", size: 20))
                                    .fontWeight(.bold)
                                Text("Bir oyun daha?")
                                    .font(.custom("monogramextended", size: 16))
                            }
                            
                        } else {
                            Text("\(self.blueTeamEmoji)")
                                .font(.system(size: 40))
                            VStack(alignment: .leading) {
                                Text("Tebrikler! \(self.blueTeamName)")
                                    .font(.custom("monogramextended", size: 20))
                                    .fontWeight(.bold)
                                Text("Yeni oyun için dokun")
                                    .font(.custom("monogramextended", size: 16))
                            }
                        }
                    }
                    .padding(25)
                    .background(Color("Ebony"))
                    .cornerRadius(80)
                    .frame(width: 300, height: 160)
                    
                }.transition(AnyTransition.asymmetric(insertion: .move(edge: .bottom), removal: .move(edge: .bottom)).combined(with: .opacity))
                .buttonStyle(NoBGButtonStyle())
                .frame(maxWidth: 600, maxHeight: 200, alignment: .center)
            }
        }
    }
}
