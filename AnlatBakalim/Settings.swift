//
//  Settings.swift
//  AnlatBakalim
//
//  Created by Steven J. Selcuk on 10.05.2020.
//  Copyright © 2020 Steven J. Selcuk. All rights reserved.
//

import SwiftUI


struct Dimension: Identifiable {
    let id: Int
    let name: String
    let seconds: Int
}




struct Settings: View {
    
    @State var roundTimeSelection = UserDefaults.standard.integer(forKey: "roundTimeSelection")
    @State var roundTime = UserDefaults.standard.integer(forKey: "time")
    @State var roundCount = UserDefaults.standard.integer(forKey: "round")
    
     @ObservedObject var Game = GameManager()
    
     @State private var backgroundColor = Color.white
    
     @State private var showingEasterEgg = false
    
    
    var seconds = [
        Dimension(id: 0, name: "10 Saniye", seconds: 10),
        Dimension(id: 1, name: "1 Dakika", seconds: 60),
        Dimension(id: 2, name: "3 Dakika", seconds: 180),
        Dimension(id: 3, name: "5 Dakika", seconds: 300)
    ]


    init() {
 
    }
    
    var body: some View {
        NavigationView {
        Form {
            Section(header: Text("Oyun Ayarları")){
            
            Picker(selection: $roundTimeSelection, label: Text("Tur Süresi")) {
                ForEach(seconds) { sec in
                    Text(sec.name)
                }
            }
            .onReceive([self.roundTimeSelection].publisher.first()) { (value) in
                settings.set(value, forKey: "roundTimeSelection")
                settings.set(self.seconds[value].seconds, forKey: "time")
            }
            .padding()
            
           
                Stepper("Tur Sayısı: \(self.Game.round)", onIncrement: {
                    self.Game.round += 1
                    settings.set(self.roundCount, forKey: "round")
                    
                }, onDecrement: {
                    self.Game.round -= 1
                    settings.set(self.roundCount, forKey: "round")
                })
                .padding(.horizontal)
                 }

            Section(header: Text("Hakkında")) {
                HStack {
                    Text("Created with ❤️ by").font(.system(size: 14)).bold()
                    Spacer()
                    Text("©  TheTabbyCat 2020").font(.caption)
                        .onTapGesture(count: 2) {
                            self.showingEasterEgg = true
                    }
                    
                }
                
                HStack {
                    Text("Kelime Havuzu Sürümü")
                    Spacer()
                    Text("1.0.0")
                }
            }
        }
        .background(
            Image("MainBGImage")
                .resizable()
                .frame(maxWidth: .infinity, maxHeight: .infinity))
        .navigationBarTitle("Ayarlar")
          
            
        }
            
        .navigationViewStyle(StackNavigationViewStyle())
        .edgesIgnoringSafeArea(.all)
        .actionSheet(isPresented: $showingEasterEgg) {
            ActionSheet(title: Text("What do you want to do?"), message: Text("There's only one choice..."), buttons: [
            
                .default(Text("Red")) { self.backgroundColor = .red },
                .default(Text("Green")) { self.backgroundColor = .green },
                .default(Text("Blue")) { self.backgroundColor = .blue },
                .cancel()
            
            ])
        }
        
    }
    
}

