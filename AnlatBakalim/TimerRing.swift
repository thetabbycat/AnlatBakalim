//
//  TimerRing.swift
//  AnlatBakalim
//
//  Created by Steven J. Selcuk on 8.05.2020.
//  Copyright © 2020 Steven J. Selcuk. All rights reserved.
//

import SwiftUI

struct TimerRing: View {
    var fontSize: Int
    var remainingTime: String

    var body: some View {

        return  HStack {
            
            Text("\(remainingTime)")
                  .foregroundColor(Color("MineShaft"))
            //    .font(Font.system(size: CGFloat(self.fontSize), design: .monospaced))
                .font(.custom("monogramextended", size: CGFloat(self.fontSize)))
                .fontWeight(.bold)

        }
    }
}
