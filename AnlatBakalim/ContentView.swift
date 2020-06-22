//
//  ContentView.swift
//  AnlatBakalim
//
//  Created by Steven J. Selcuk on 8.05.2020.
//  Copyright © 2020 Steven J. Selcuk. All rights reserved.
//

import SwiftUI
import SwiftUICardStack


let settings = UserDefaults.standard
let screen = UIScreen.main.bounds
let reachability = try! Reachability()

struct ContentView: View {
    @ObservedObject var fetcher = Fetcher()
    @ObservedObject var Game = GameManager()
    
    @ObservedObject var TheSoundManager = SoundManager()
    var isIpad = UIDevice.current.model.hasPrefix("iPad")
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    @State var reloadToken = UUID()
    @State var fulltime = UserDefaults.standard.integer(forKey: "time")
    @State var timeRemaining = UserDefaults.standard.integer(forKey: "time")
    
    @State private var isActive = true
    @State private var removeRound = false
    @State private var isWrong = false
    @State private var isRight = false
    @State private var isSettingsOpen = false
    

    init() {
        reachability.whenReachable = { reachability in
            if reachability.connection == .wifi {
                print("wifi")
                Fetcher().refresh()
            } else {
                print("celluar")
                Fetcher().refresh()
            }
        }
        reachability.whenUnreachable = { _ in
            Fetcher().getLocalWords()
        }
        
        
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }
    
    func refreshFullTime (time: Int) {
        settings.set(time, forKey: "time")
        self.reloadToken = UUID()
        self.Game.timeRemaining = UserDefaults.standard.integer(forKey: "time")
    }
    
    func textForPlaybackTime(time: TimeInterval) -> String {
        if !time.isNormal {
            return "00:00"
        }
        let hours = Int(floor(time / 3600))
        let minutes = Int(floor((time / 60).truncatingRemainder(dividingBy: 60)))
        let seconds = Int(floor(time.truncatingRemainder(dividingBy: 60)))
        let minutesAndSeconds = NSString(format: "%02d:%02d", minutes, seconds) as String
        if hours > 0 {
            return NSString(format: "%02d:%@", hours, minutesAndSeconds) as String
        } else {
            return minutesAndSeconds
        }
    }
    
    var body: some View {
        ZStack {
            Button(action: {
                self.isSettingsOpen.toggle()
            }) {
                HStack {
                    Image("Settings")
                        .antialiased(true)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: 48, maxHeight: 48, alignment: .center)
                }
            }
            .buttonStyle(MyButtonStyle())
            .offset(x:(screen.width / 2 - 50), y:-(screen.height / 2 - 60))
            VStack {
                if (self.isWrong) {
                    Image("Wrong")
                        .resizable()
                        .frame(width: 128, height: 128)
                        .offset(x: 0, y: -(screen.height / 2 - 120))
                        //     .transition(AnyTransition.asymmetric(insertion: .slide, removal: .move(edge: .bottom)))
                        .transition( AnyTransition.asymmetric(insertion: .scale, removal: .scale).combined(with: .opacity))
                        .animation(.interpolatingSpring(mass: 1.0,
                                                        stiffness: 100.0,
                                                        damping: 10,
                                                        initialVelocity: 0))
                    
                } else if (self.isRight) {
                    Image("True")
                        .resizable()
                        .frame(width: 128, height: 128)
                        .offset(x: 0, y: -(screen.height / 2 - 120))
                        .transition( AnyTransition.asymmetric(insertion: .scale, removal: .scale).combined(with: .opacity))
                        .animation(.interpolatingSpring(mass: 1.0,
                                                        stiffness: 100.0,
                                                        damping: 10,
                                                        initialVelocity: 0))
                }
            }
            VStack {
                if (self.Game.ended == false && self.Game.round >= 1) {
                    HStack {
                        VStack(spacing: 1) {
                            Image("TeamRed")
                                .resizable()
                                .frame(width: 64, height: 64)
                                .scaleEffect(self.Game.currentTeam == "red" ? 1.3 : 1)
                                .transition( AnyTransition.asymmetric(insertion: .scale, removal: .scale).combined(with: .opacity))
                                .animation(.interpolatingSpring(mass: 1.0,
                                                                stiffness: 100.0,
                                                                damping: 10,
                                                                initialVelocity: 0))
                            Text("\(self.Game.teamRed)")
                                .foregroundColor(.black)
                                .font(Font.system(size: self.isIpad ? 64 : 32, design: .monospaced))
                                .fontWeight(.bold)
                                .transition( AnyTransition.asymmetric(insertion: .scale, removal: .scale).combined(with: .opacity))
                        }
                        
                        VStack {
                            Text(self.Game.round > 1 ? "Kalan tur: \(self.Game.round)" : "⚠️ Son tur")
                                .foregroundColor(.black)
                                .font(Font.system(size: self.isIpad ? 18 : 12, design: .monospaced))
                            TimerRing(fontSize: self.isIpad ? 64 : 32, remainingTime: String(textForPlaybackTime(time: TimeInterval(self.Game.timeRemaining))))
                            
                        }.padding(.all)
                        VStack(spacing: 1) {
                            Image("TeamBlue")
                                .resizable()
                                .frame(width: 64, height: 64)
                                .scaleEffect(self.Game.currentTeam == "blue" ? 1.3 : 1)
                                .transition( AnyTransition.asymmetric(insertion: .scale, removal: .scale).combined(with: .opacity))
                                .animation(.interpolatingSpring(mass: 1.0,
                                                                stiffness: 100.0,
                                                                damping: 10,
                                                                initialVelocity: 0))
                            Text("\(self.Game.teamBlue)")
                                .foregroundColor(.black)
                                .font(Font.system(size: self.isIpad ? 64 : 32, design: .monospaced))
                                .fontWeight(.bold)
                                .transition( AnyTransition.asymmetric(insertion: .scale, removal: .scale).combined(with: .opacity))
                        }
                    }
                } else {
                    Text("Game ended")
                          HStack {
                    
                                    Button(action: {
                                        self.reloadToken = UUID()
                                        self.fetcher.words = self.fetcher.words.shuffled()
                                        self.Game.timeRemaining = UserDefaults.standard.integer(forKey: "time")
                                        self.Game.round = UserDefaults.standard.integer(forKey: "round")
                                        self.Game.ended = false
                                        self.Game.isActive = true
                                    }) {
                                        Text("Reload")
                                   }
                    
                                    Button(action: {
                    
                                       self.fetcher.refresh()
                                   }) {
                                       Text("Satın Al")
                                   }
                    
                               }
                }


                if(self.Game.isActive == true) {
                    CardStack(
                        direction: LeftRight.direction,
                        data: self.fetcher.words,
                        onSwipe: { word, direction in
                            print("Swiped \(word.word ?? "No word") to \(direction)")
                            print(direction)
                            if (direction == .left) {
                                //    self.TheSoundManager.wrong()
                                self.isWrong = true
                                self.isRight = false
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                    withAnimation(.easeInOut) {
                                        self.isWrong = false
                                    }
                                }
                            } else if (direction == .right) {
                                self.isWrong = false
                                self.isRight = true
                                if  (self.Game.currentTeam == "red") {
                                    self.Game.teamRed += 1
                                } else {
                                    self.Game.teamBlue += 1
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                    withAnimation(.easeInOut) {
                                        self.isRight = false
                                    }
                                }
                            }
                    },
                        content: { word, direction, _ in
                            SingleWordItem(item: word, isIpad: self.isIpad, direction: direction )
                    }
                    )
                        .id(reloadToken)
                        .environment(\.cardStackConfiguration, CardStackConfiguration(
                            maxVisibleCards: 3,
                            swipeThreshold: 0.3,
                            cardOffset: 20,
                            cardScale: 0.2,
                            animation: .spring(response: 0.3, dampingFraction: 0.8, blendDuration: 0.1)
                        ))
                        .padding()
                        .scaledToFit()
                        .frame(maxWidth: isIpad ? screen.width / 2: screen.width - 10 , maxHeight: isIpad ? screen.width / 2 : screen.width - 10, alignment: .center)
                        .transition( AnyTransition.asymmetric(insertion: .move(edge: .bottom), removal: .move(edge: .bottom)).combined(with: .opacity))
                    
                } else {
                    Button(action: {
                        self.Game.timeRemaining = UserDefaults.standard.integer(forKey: "time")
                        if(self.Game.currentTeam == "red") {
                            self.Game.currentTeam = "blue"
                        } else if(self.Game.currentTeam == "blue"){
                            self.Game.currentTeam = "red"
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now()) {
                            withAnimation(.interpolatingSpring(mass: 1.0,
                                                               stiffness: 100.0,
                                                               damping: 10,
                                                               initialVelocity: 0)) {
                                                                self.Game.isActive = true
                            }
                        }
                    }) {
                        if(self.Game.currentTeam == "red") {
                            VStack {
                                Text("Sıra mavi takımda")
                                    .foregroundColor(Color("MineShaft"))
                                    .font(.custom("Kalam Bold", size: self.isIpad ? 32 : 28))
                                Text("Başlamak için dokun")
                                    .foregroundColor(Color("MineShaft"))
                                    .font(.custom("Kalam Bold", size: self.isIpad ? 22 : 12))
                            }                   .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center)
                            
                        } else if(self.Game.currentTeam == "blue"){
                            VStack {
                                Text("Sıra kırmızı takımda")
                                    .foregroundColor(Color("MineShaft"))
                                    .font(.custom("Kalam Bold", size: self.isIpad ? 22 : 28))
                                Text("Başlamak için dokun")
                                    .foregroundColor(Color("MineShaft"))
                                    .font(.custom("Kalam Bold", size: self.isIpad ? 22 : 12))
                            }                   .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center)
                        }
                    }
                    .transition( AnyTransition.asymmetric(insertion: .move(edge: .bottom), removal: .move(edge: .bottom)).combined(with: .opacity))
                    .buttonStyle(GoodButtonStyle())
                    .frame(maxWidth: 600, maxHeight: 200, alignment: .center)
                    
                    
                }
            }
            .onReceive(timer) { time in
                guard self.Game.isActive else { return }
                    if self.Game.timeRemaining > 0 {
                        self.Game.timeRemaining -= 1
                    }
                
                 if (self.Game.round >= 1 ) {
                    
                    if (self.Game.timeRemaining <= 1 ) {
                        DispatchQueue.main.asyncAfter(deadline: .now()) {
                            withAnimation(.interpolatingSpring(mass: 1.0,
                                                               stiffness: 100.0,
                                                               damping: 10,
                                                               initialVelocity: 0)) {
                                                                self.Game.isActive = false
                                                                self.Game.timeRemaining = UserDefaults.standard.integer(forKey: "time")
                            }
                        }
                        
                        self.Game.isActive = false
                      
                        
                        if (self.removeRound == true ) {
                              self.Game.round -= 1
                            self.removeRound.toggle()
                        } else {
                            self.removeRound.toggle()
                        }
                        
                    }
                } else if (self.Game.round == 0 ) {
                    self.Game.ended = true
                     self.Game.isActive = false
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
               self.Game.isActive = false
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                self.Game.isActive = true
            }
            .onAppear {
                
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center)
        }
            
        .background(
            Image("MainBGImage")
                .resizable()
                .frame(maxWidth: .infinity, maxHeight: .infinity))
            .edgesIgnoringSafeArea(.all)
            
            .sheet(isPresented: self.$isSettingsOpen ) {
                Settings()
                
        }
    }
}
