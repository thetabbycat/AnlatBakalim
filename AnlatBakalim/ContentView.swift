//
//  ContentView.swift
//  AnlatBakalim
//
//  Created by Steven J. Selcuk on 8.05.2020.
//  Copyright © 2020 Steven J. Selcuk. All rights reserved.
//
import UIKit
import SwiftUI
import SwiftUICardStack


let settings = UserDefaults.standard
let screen = UIScreen.main.bounds
// let reachability = try! Reachability()

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
    
    @State var redTeamEmoji = "🥑"
    @State var blueTeamEmoji = "🚀"
    
    
    
    init() {
         Fetcher().getLocalWords()
     //   reachability.whenReachable = { reachability in
     //       if reachability.connection == .wifi {
     //           print("wifi")
     //           Fetcher().getLocalWords()
     //       } else {
     //           print("celluar")
     //           Fetcher().getLocalWords()
     //
     //       }
     //   }
     //   reachability.whenUnreachable = { _ in
     //       Fetcher().getLocalWords()
     //   }
     //   Fetcher().getLocalWords()
     //   do {
     //       try reachability.startNotifier()
     //   } catch {
     //       print("Unable to start notifier")
     //   }
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
                 self.TheSoundManager.menu()
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
                            Text(self.redTeamEmoji)
                                .font(Font.system(size: 48))
                                .transition( AnyTransition.asymmetric(insertion: .scale, removal: .scale).combined(with: .opacity))
                                .frame(maxWidth: 64, maxHeight: 64, alignment: .center)
                                .padding(5)
                                .contextMenu {
                                    Button(action: {
                                        self.redTeamEmoji = "🥑"
                                    }) {
                                        Text("🥑 Avacadolar")
                                    }
                                    Button(action: {
                                        self.redTeamEmoji = "🧠"
                                    }) {
                                        Text("🧠")
                                    }
                                    Button(action: {
                                        self.redTeamEmoji = "🔥"
                                    }) {
                                        Text("🔥")
                                    }
                                    Button(action: {
                                        self.redTeamEmoji = "🐈"
                                    }) {
                                        Text("🐈")
                                    }
                            }
                            Text("\(self.Game.teamRed)")
                                .foregroundColor(Color("MineShaft"))
                                //      .font(Font.system(size: self.isIpad ? 64 : 32, design: .monospaced))
                                .font(.custom("monogramextended", size: self.isIpad ? 64 : 48))
                                .fontWeight(.bold)
                                .transition( AnyTransition.asymmetric(insertion: .scale, removal: .scale).combined(with: .opacity))
                        }
                        
                        VStack {
                            Text(self.Game.round > 1 ? "Kalan tur: \(self.Game.round)" : "⚠️ Son tur")
                                .foregroundColor(Color("MineShaft"))
                                //  .font(Font.system(size: self.isIpad ? 18 : 12, design: .monospaced))
                                .font(.custom("monogramextended", size: self.isIpad ? 32 : 28))
                            TimerRing(fontSize: self.isIpad ? 64 : 48, remainingTime: String(textForPlaybackTime(time: TimeInterval(self.Game.timeRemaining))))
                            
                        }.padding(.all)
                        VStack(spacing: 1) {
                            Text(self.blueTeamEmoji)
                                .font(Font.system(size: 48))
                                .transition( AnyTransition.asymmetric(insertion: .scale, removal: .scale).combined(with: .opacity))
                                .frame(maxWidth: 64, maxHeight: 64, alignment: .center)
                                .padding(5)
                                .contextMenu {
                                    Button(action: {
                                        self.blueTeamEmoji = "🚀"
                                    }) {
                                        Text("🚀 Roket Takımı")
                                    }
                                    Button(action: {
                                        self.blueTeamEmoji = "🍅"
                                    }) {
                                        Text("🍅")
                                    }
                                    Button(action: {
                                        self.blueTeamEmoji = "☠️"
                                    }) {
                                        Text("☠️")
                                    }
                                    
                                    Button(action: {
                                        self.blueTeamEmoji = "🦮"
                                    }) {
                                        Text("🦮")
                                    }
                            }
                            Text("\(self.Game.teamBlue)")
                                .foregroundColor(Color("MineShaft"))
                                //      .font(Font.system(size: self.isIpad ? 64 : 32, design: .monospaced))
                                .font(.custom("monogramextended", size: self.isIpad ? 64 : 48))
                                .fontWeight(.bold)
                                .transition( AnyTransition.asymmetric(insertion: .scale, removal: .scale).combined(with: .opacity))
                        }
                    }
                } else {

                        
                        Button(action: {
                            self.reloadToken = UUID()
                            self.fetcher.words = self.fetcher.words.shuffled()
                            self.Game.timeRemaining = self.Game.fulltime
                            self.Game.round = UserDefaults.standard.integer(forKey: "round")
                            self.Game.teamBlue = 0
                            self.Game.teamRed = 0
                             self.TheSoundManager.newGame()
                            self.Game.ended = false
                            self.Game.isActive = false
                        }) {
                            VStack {
                                if (self.Game.teamRed > self.Game.teamBlue) {
                                    Text("Kazanan \(self.redTeamEmoji)")
                                        .foregroundColor(.black)
                                        .font(.custom("Kalam Bold", size: self.isIpad ? 64 : 32))
                                } else if (self.Game.teamRed == self.Game.teamBlue) {
                                    Text("Kazanan yok")
                                        .foregroundColor(.black)
                                        .font(.custom("Kalam Bold", size: self.isIpad ? 64 : 32))
                                } else {
                                    Text("Kazanan \(self.blueTeamEmoji)")
                                        .foregroundColor(.black)
                                        .font(.custom("Kalam Bold", size: self.isIpad ? 64 : 32))
                                }
                                      Text("Tekrar oynamak için dokun")
                                        .foregroundColor(.black)
                                        .font(.custom("Kalam Bold", size: self.isIpad ? 18 : 22))
                            }
                             .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center)
            
                        }   .transition( AnyTransition.asymmetric(insertion: .move(edge: .bottom), removal: .move(edge: .bottom)).combined(with: .opacity))
                            .buttonStyle(GoodButtonStyle())
                            .frame(maxWidth: 600, maxHeight: 200, alignment: .center)
                }

                if(self.Game.isActive == true) {
                    CardStack(
                        direction: LeftRight.direction,
                        data: self.fetcher.words,
                        onSwipe: { word, direction in
                            print("Swiped \(word.word ?? "No word") to \(direction)")
                            print(direction)
                            if (direction == .left) {

                                self.isWrong = true
                                self.isRight = false
                                self.TheSoundManager.wrong()
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                    withAnimation(.easeInOut) {
                                        self.isWrong = false
                                    }
                                }
                            } else if (direction == .right) {
                                self.isWrong = false
                                self.isRight = true
                                 self.TheSoundManager.right()
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
                        DispatchQueue.main.asyncAfter(deadline: .now()) {
                            withAnimation(.interpolatingSpring(mass: 1.0,
                                                               stiffness: 100.0,
                                                               damping: 10,
                                                               initialVelocity: 0)) {
                                                               self.fetcher.words = self.fetcher.words.shuffled()
                                                                self.Game.isActive = true
                                                                  self.TheSoundManager.nextRound()
                                                                if(self.Game.currentTeam == "red") {
                                                                    self.Game.currentTeam = "blue"
                                                                } else if(self.Game.currentTeam == "blue"){
                                                                    self.Game.currentTeam = "red"
                                                                }
                            }
                        }
                    }) {
                        
                        if (self.Game.ended == false &&  self.Game.round > 0 ) {
                            if(self.Game.currentTeam == "red") {
                                VStack {
                                    Text("\(self.blueTeamEmoji)")
                                        .foregroundColor(Color("MineShaft"))
                                        .font(.custom("Kalam Bold", size: self.isIpad ? 32 : 28))
                                    Text("Başlamak için dokun")
                                        .foregroundColor(Color("MineShaft"))
                                        .font(.custom("Kalam Bold", size: self.isIpad ? 22 : 12))
                                }                   .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center)
                                
                            } else if(self.Game.currentTeam == "blue"){
                                VStack {
                                    Text("\(self.redTeamEmoji)")
                                        .foregroundColor(Color("MineShaft"))
                                        .font(.custom("Kalam Bold", size: self.isIpad ? 22 : 28))
                                    Text("Başlamak için dokun")
                                        .foregroundColor(Color("MineShaft"))
                                        .font(.custom("Kalam Bold", size: self.isIpad ? 22 : 12))
                                }                   .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center)
                            }
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
                
                if (self.Game.round > 0 ) {
                    if (self.Game.timeRemaining <= 1 ) {
                        DispatchQueue.main.asyncAfter(deadline: .now() ) {
                            withAnimation(.interpolatingSpring(mass: 1.0,
                                                               stiffness: 100.0,
                                                               damping: 10,
                                                               initialVelocity: 0)) {
                                                                self.Game.isActive = false
                                                                self.Game.timeRemaining = UserDefaults.standard.integer(forKey: "time")
                            }
                        }
                        
                        withAnimation(.easeInOut) {
                            self.Game.isActive = false
                        }

                        if (self.removeRound == true ) {
                            self.Game.round -= 1
                            self.removeRound.toggle()
                        } else {
                            self.removeRound.toggle()
                        }
                      
                    }
                } else if (self.Game.round <= 1 ) {
                    withAnimation(.easeInOut) {
                         self.TheSoundManager.endGame()
                        self.Game.ended = true
                        self.Game.isActive = false
                    }
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
