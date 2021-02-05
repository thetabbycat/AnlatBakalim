//
//  PromotionButton.swift
//  Anlat Bakalım
//
//  Created by Steven J. Selcuk on 16.01.2021.
//  Copyright © 2021 Steven J. Selcuk. All rights reserved.
//

import SwiftUI

struct PromotionButton: View {
    
    var onTap: () -> Void
    

    var body: some View {
        Button(action: {
            self.onTap()
        }) {
            HStack(alignment: .center) {
                Text("🤷‍♂️")
                    .font(.system(size: 40))
                VStack(alignment: .leading) {
                    Text("Kartlar bitti!")
                        .font(.custom("monogramextended", size: 20))
                        .fontWeight(.bold)
                    Text("Merak etme daha fazlası var! Sürekli güncellenen kelime setini \nsatın almak için dokun.")
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
    }
}

