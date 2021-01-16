//
//  CardStackView.swift
//  Anlat Bakalım
//
//  Created by Steven J. Selcuk on 16.01.2021.
//  Copyright © 2021 Steven J. Selcuk. All rights reserved.
//

import SwiftUI
import CardStack

struct CardStackView: View {
    var wordStack: [Word]
    var onSwipeAction: (_ direction: LeftRight) -> Void
    var isIpad: Bool
    var swipeCounter: Int
    
    
    var body: some View {
        CardStack(direction: LeftRight.direction, data: self.wordStack, id: \Word.id, onSwipe: { _, direction in
            self.onSwipeAction(direction)
        }, content: { word, direction, _ in
            SingleWordItem(item: word, isIpad: self.isIpad, swipeCount: self.swipeCounter, count: self.wordStack.count, direction: direction)
        })
        .environment(\.cardStackConfiguration, CardStackConfiguration(
            maxVisibleCards: 3,
            swipeThreshold: 0.3,
            cardOffset: 20,
            cardScale: 0.2,
            animation: .spring(response: 0.3, dampingFraction: 0.8, blendDuration: 0.1)
        ))
        .padding()
        .scaledToFit()
        .frame(maxWidth: isIpad ? screen.width / 2 : screen.width - 10, maxHeight: isIpad ? screen.width / 2 : screen.width - 10, alignment: .center)
        .transition(AnyTransition.asymmetric(insertion: .move(edge: .bottom), removal: .move(edge: .bottom)).combined(with: .opacity))
    }
}

