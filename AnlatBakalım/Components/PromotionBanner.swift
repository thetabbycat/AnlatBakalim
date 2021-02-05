//
//  PromotionBanner.swift
//  Anlat Bakalım
//
//  Created by Steven J. Selcuk on 17.01.2021.
//  Copyright © 2021 Steven J. Selcuk. All rights reserved.
//

import SwiftUI

struct PromotionItem: Identifiable {
    let id: Int
    let emoji: String
    let title: String
    let desc: String
}

var promotText = [
    PromotionItem(id: 0, emoji: "🥳", title: "Eğlence devam etsin!", desc: "Hep aynı kelimeler çıkmasın!\n AnlatBakalım Pro ile daha fazlasını oyna. Satın almak için dokun."),
    PromotionItem(id: 1, emoji: "🎉", title: "Hep aynı kelimeler?", desc: "Buraya dokun ve sürekli güncellenen kelime kart setinine sahip\nAnlatBakalım Pro'yu satın al."),
    PromotionItem(id: 2, emoji: "🔒", title: "Premium Özellikleri aç", desc: "AnlatBakalım Pro ile sürekli güncellenen kelime setine erişebilir\nve takım emojilerini değiştirebilirsin! "),
    PromotionItem(id: 3, emoji: "🧐", title: "Premium Özellikleri aç", desc: "Kolay kelimeler sana göre değil mi?\nAnlatBakalım Pro'da her zorluk seviyesi için daha fazlası var."),
]

struct PromotionBanner: View {
    var onTap: () -> Void
    var isIpad: Bool

    let item: PromotionItem

    var body: some View {
        Button(action: {
            self.onTap()
        }) {
            HStack(alignment: .center) {
                Text(item.emoji)
                    .font(.system(size: 40))
                VStack(alignment: .leading) {
                    Text(item.desc)
                        .font(.custom("monogramextended", size: 16))
                }
            }
            .padding(15)
            .background(Color("Ebony"))
            .cornerRadius(8)
            .frame(minWidth: 0, maxWidth: screen.width / 2 + 200, minHeight: 160, maxHeight: 160, alignment: .center)
            //   .frame(width: .infinity, height: 160)
        }
      //  .shadow(color: Color("Ebony").opacity(0.6), radius: 20, x: 0, y: 20)
        .transition(AnyTransition.asymmetric(insertion: .move(edge: .bottom), removal: .move(edge: .bottom)).combined(with: .opacity))
        .buttonStyle(NoBGButtonStyleWhite())
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 160, maxHeight: 260, alignment: .center)
        .offset(x: self.isIpad ? -(screen.width / 2 ) + 240 : -40, y: -(screen.height / 2 - 85))
    }
}
