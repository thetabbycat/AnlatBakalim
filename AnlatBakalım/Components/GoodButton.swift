//
//  GoodButton.swift
//  AnlatBakalim
//
//  Created by Steven J. Selcuk on 21.06.2020.
//  Copyright © 2020 Steven J. Selcuk. All rights reserved.
//

import SwiftUI

struct GoodButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .background(
                
                Image("ButtonScreen")
                    .resizable()
                    .frame(maxWidth: .infinity, maxHeight: .infinity))
          
            .padding(45)
 
            .scaleEffect(configuration.isPressed ? 0.93 : 1.0)
    }
}

struct NoBGButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .padding(45)
            .scaleEffect(configuration.isPressed ? 1.1 : 1)
    }
}
