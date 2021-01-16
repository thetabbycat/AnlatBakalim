//
//  PlayButton.swift
//  Anlat Bakalım
//
//  Created by Steven J. Selcuk on 16.01.2021.
//  Copyright © 2021 Steven J. Selcuk. All rights reserved.
//

import SwiftUI

struct PlayButton: View {
    
    var onTap: () -> Void
    var ended: Bool
    var round: Int
    var currentTeam: String
    
    var redTeamEmoji: String
    var blueTeamEmoji: String
    var redTeamName: String
    var blueTeamName: String
    
    var body: some View {
        Button(action: {
            self.onTap()
        }) {
            if self.ended == false && self.round > 0 {
                HStack(alignment: .center) {
                    if self.currentTeam == "red" {
                        Text("\(self.blueTeamEmoji)")
                            .font(.system(size: 40))
                        
                    } else {
                        Text("\(self.redTeamEmoji)")
                            .font(.system(size: 40))
                    }
                    VStack(alignment: .leading) {
                        if self.currentTeam == "red" {
                            Text(" \(self.blueTeamName) oynuyor")
                                .font(.custom("monogramextended", size: 20))
                                .fontWeight(.bold)
                        } else {
                            Text(" \(self.redTeamName) oynuyor")
                                .font(.custom("monogramextended", size: 20))
                                .fontWeight(.bold)
                        }
                        Text("Başlamak için buraya dokun")
                            .font(.custom("monogramextended", size: 16))
                    }
                }
                .padding(25)
                .background(Color("Ebony"))
                .cornerRadius(80)
                .frame(width: 300, height: 160)
                .shadow(color: Color("Ebony").opacity(0.6), radius: 20, x: 0, y: 20)
            }
        }
        .transition(AnyTransition.asymmetric(insertion: .move(edge: .bottom), removal: .move(edge: .bottom)).combined(with: .opacity))
        .buttonStyle(NoBGButtonStyle())
        .frame(maxWidth: 600, maxHeight: 200, alignment: .center)
    }
}

