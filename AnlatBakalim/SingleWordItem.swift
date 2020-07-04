//
//  SingleWordItem.swift
//  AnlatBakalim
//
//  Created by Steven J. Selcuk on 8.05.2020.
//  Copyright © 2020 Steven J. Selcuk. All rights reserved.
//

import SwiftUI
import SwiftUICardStack


struct ForbiddenWordItem: View {
    var forb: String
    var isIpad: Bool
    
    var body: some View {
        VStack {
            Text("❌ \(forb)")
                .foregroundColor(.black)
                .font(.custom("Kalam", size: self.isIpad ? 22 : 22))
        }
    }
}

struct SingleWordItem: View {
    
    var item: Word
    var isIpad: Bool
    let direction: LeftRight?

    
    var body: some View {
        
        GeometryReader { geo in
            ZStack {
                VStack {
                    Text("\(self.item.word ?? "Kelime" )" )
                        .foregroundColor(.black)
                        .font(.custom("Kalam Bold", size: self.isIpad ? 64 : 32))
                        //          .shadow(color: .black, radius: 5, x: 1, y: 5)
                        .padding(.all, 30)
                    
                    //     Text("Yasaklı Kelimeler")
                    //          .font(.custom("Kalam Bold", size: self.isIpad ? 22 : 22))
                    
                    VStack(alignment: .leading) {
                        if self.item.forbiddenWords?.isEmpty == false {
                            ForEach((NSKeyedUnarchiver.unarchiveObject(with: self.item.forbiddenWords!) as? [String])?.shuffled().prefix(5) ?? ["Yasaklı Kelime"], id: \.self) {
                                ForbiddenWordItem(forb: "\($0)", isIpad: self.isIpad )
                            }
                        }
                    }
                }
            }
        }
        .background(
            Image("CardBGImage")
                .resizable()
                .frame(maxWidth: .infinity, maxHeight: .infinity))
            //   .opacity(direction == .right ? 0 : 1)
            .cornerRadius(6)
            .drawingGroup()
            .shadow(color: Color("Ebony").opacity(0.6), radius: 20, x: 0, y: 20)
        //     .animation(.linear)
    }
}


struct SingleWordItem_Previews: PreviewProvider {
    static var previews: some View {
        /*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
    }
}
