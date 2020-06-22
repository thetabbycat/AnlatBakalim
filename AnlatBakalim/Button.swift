//
//  Button.swift
//  AnlatBakalim
//
//  Created by Steven J. Selcuk on 20.06.2020.
//  Copyright © 2020 Steven J. Selcuk. All rights reserved.
//

import SwiftUI

struct MyButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .background(Color.gray.opacity(0))
            .frame(minWidth: 40, minHeight: 40, alignment: .center)
            .padding(5)
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
    }
}
