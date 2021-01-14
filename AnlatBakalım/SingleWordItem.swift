//
//  SingleWordItem.swift
//  AnlatBakalim
//
//  Created by Steven J. Selcuk on 8.05.2020.
//  Copyright © 2020 Steven J. Selcuk. All rights reserved.
//

import SwiftUI
import CardStack

struct ForbiddenWordItem: View {
    var forb: String
    var isIpad: Bool

    var body: some View {
        VStack {
            Text("❌ \(forb)")
                .foregroundColor(.black)
                .font(.custom("Kalam", size: self.isIpad ? 29 : 22))
        }
    }
}

struct SingleWordItem: View {
    var item: Word
    var isIpad: Bool
    var swipeCount: Int
    var count: Int
    let direction: LeftRight?

    var body: some View {
        GeometryReader { _ in
            if swipeCount == count {
                VStack {
                    Text("Daha fazla kelime")
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.black)
                        .font(.custom("Kalam Bold", size: self.isIpad ? 48 : 32))
                        .padding(.all, 30)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Text("Satın almak için dokun")
                }
                
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center)
            } else {
                VStack {
                    Text("\(self.item.word ?? "...")")
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.black)
                        .font(.custom("Kalam Bold", size: self.isIpad ? 48 : 32))
                        .padding(.all, 30)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    VStack(alignment: .leading) {
                        if self.item.forbiddenWords?.isEmpty == false {
                            ForEach((NSKeyedUnarchiver.unarchiveObject(with: self.item.forbiddenWords!) as? [String])?.shuffled().prefix(5) ?? ["Yasaklı Kelime"], id: \.self) {
                                ForbiddenWordItem(forb: "\($0)", isIpad: self.isIpad)
                            }
                        }
                    }
                }
                
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center)
            }
            
        }
        .background(
            Image("CardBGImage")
                .resizable()
                .frame(maxWidth: .infinity, maxHeight: .infinity))
        //   .opacity(direction == .right ? 0 : 1)
      //  .cornerRadius(6)
       // .drawingGroup()
        .shadow(color: Color("Ebony").opacity(0.6), radius: 20, x: 0, y: 20)
        //     .animation(.linear)
    }
}

struct SingleWordItem_Previews: PreviewProvider {
    static var previews: some View {
        /*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
    }
}
