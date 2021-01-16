//
//  TrueOrFalseIcons.swift
//  Anlat Bakalım
//
//  Created by Steven J. Selcuk on 16.01.2021.
//  Copyright © 2021 Steven J. Selcuk. All rights reserved.
//

import SwiftUI

struct TrueOrFalseIcons: View {
    
    var isWrong: Bool
    var isRight: Bool
    
    var body: some View {
        VStack {
            if self.isWrong {
                Image("Wrong")
                    .resizable()
                    .frame(width: 128, height: 128)
                    .offset(x: 0, y: -(screen.height / 2 - 120))
                    //     .transition(AnyTransition.asymmetric(insertion: .slide, removal: .move(edge: .bottom)))
                    .transition(AnyTransition.asymmetric(insertion: .scale, removal: .scale).combined(with: .opacity))
                    .animation(.interpolatingSpring(mass: 1.0,
                                                    stiffness: 100.0,
                                                    damping: 10,
                                                    initialVelocity: 0))
                
            } else if self.isRight {
                Image("True")
                    .resizable()
                    .frame(width: 128, height: 128)
                    .offset(x: 0, y: -(screen.height / 2 - 120))
                    .transition(AnyTransition.asymmetric(insertion: .scale, removal: .scale).combined(with: .opacity))
                    .animation(.interpolatingSpring(mass: 1.0,
                                                    stiffness: 100.0,
                                                    damping: 10,
                                                    initialVelocity: 0))
            }
        }
    }
}

