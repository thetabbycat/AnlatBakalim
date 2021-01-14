
import CardStack
import ConfettiView
import ExytePopupView
import SwiftUI
import UIKit

let settings = UserDefaults.standard
let screen = UIScreen.main.bounds
let reachability = try! Reachability()

struct ContentView: View {
    @ObservedObject var fetcher = Fetcher()
    @ObservedObject var Game = GameManager()
    @ObservedObject var TheSoundManager = SoundManager()

    var isIpad = UIDevice.current.model.hasPrefix("iPad")

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    @State private var isActive = true
    @State private var removeRound = false
    @State private var isWrong = false
    @State private var isRight = false
    @State private var isSettingsOpen = false
    @State private var showPromotion = false

    @State var redTeamEmoji = "🥑"
    @State var blueTeamEmoji = "🚀"
    @State var redTeamName = "Avokadolar"
    @State var blueTeamName = "Roket Takımı"
    @State var currentTeamName: String = UserDefaults.standard.string(forKey: "currentTeam") ?? "blue"

    @State var swipeCounter = 0
    @State var gradient1 = [UIColor.red, UIColor.purple]
    @State var gradient2 = [UIColor.purple, UIColor.orange]

    // var isPremium = UserDefaults.standard.optionalBool(forKey: "isSubscribed") ?? false
    var isPremium = false
    init() {
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
        reachability.whenUnreachable = { _ in
            print("no connection")
        }

        UIApplication.shared.isIdleTimerDisabled = true
    }

    func refresh() {
        Game.timeRemaining = UserDefaults.standard.integer(forKey: "time")
        Game.fulltime = UserDefaults.standard.integer(forKey: "time")
        Game.round = UserDefaults.standard.optionalInt(forKey: "round") ?? 5
        TheSoundManager.menu()
        Game.ended = false
    }

    func refreshFullTime(time: Int) {
        settings.set(time, forKey: "time")
        Game.timeRemaining = UserDefaults.standard.integer(forKey: "time")
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

    let confettiView = ConfettiView(confetti: [
        .text("🎉"),
        .text("⭐️"),
        .text("🥳"),
        .text("🥳"),
    ])

    let generator = UIImpactFeedbackGenerator(style: .heavy)

    var body: some View {
        ZStack {
      

            Button(action: {
                generator.impactOccurred()

                // self.showPromotion.toggle()
                self.isSettingsOpen.toggle()
                self.TheSoundManager.menu()
            }) {
                HStack {
                    Image("Settings")
                        .antialiased(true)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: isIpad ? 64 : 48, maxHeight: isIpad ? 64 : 48, alignment: .center)
                }
            }
            .buttonStyle(MyButtonStyle())
            .offset(x: self.isIpad ? screen.width / 2 - 70 : screen.width / 2 - 40, y: -(screen.height / 2 - 100))

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

            VStack {
                if self.Game.ended == false && self.Game.round >= 1 {
                    HStack {
                        VStack(spacing: 1) {
                            Text(self.redTeamEmoji)
                                .font(Font.system(size: 48))
                                .frame(maxWidth: 64, maxHeight: 64, alignment: .center)
                                .if(self.Game.currentTeam == "red") { $0.multicolorGlow(rotation: self.Game.teamRed) }
                                .modifier(ShakeEffect(shakes: self.Game.teamRed * 2))
                                .if(isPremium) { $0.contextMenu {
                                    Button(action: {
                                        self.redTeamEmoji = "🥑"
                                        self.redTeamName = "Avokadolar"
                                    }) {
                                        Text("🥑 Avokadolar")
                                    }
                                    Button(action: {
                                        self.redTeamEmoji = "🥜"
                                        self.redTeamName = "Fıstıklar"
                                    }) {
                                        Text("🥜 Fıstıklar")
                                    }
                                    Button(action: {
                                        self.redTeamEmoji = "🌼"
                                        self.redTeamName = "Çiçekler"
                                    }) {
                                        Text("🌼 Çiçekler")
                                    }
                                    Button(action: {
                                        self.redTeamEmoji = "🐈"
                                        self.redTeamName = "Kedi Kuyruğu"
                                    }) {
                                        Text("🐈 Kedi Kuyruğu")
                                    }
                                } }

                            Text("\(self.Game.teamRed)")
                                .foregroundColor(Color("MineShaft"))
                                //      .font(Font.system(size: self.isIpad ? 64 : 32, design: .monospaced))
                                .font(.custom("monogramextended", size: self.isIpad ? 72 : 48))
                                .fontWeight(.bold)
                                .transition(AnyTransition.asymmetric(insertion: .scale, removal: .scale).combined(with: .opacity))
                        }

                        VStack {
                            Text(self.Game.round > 1 ? "Kalan tur: \(self.Game.round)" : "⚠️ Son tur")
                                .foregroundColor(Color("MineShaft"))
                                //  .font(Font.system(size: self.isIpad ? 18 : 12, design: .monospaced))
                                .font(.custom("monogramextended", size: self.isIpad ? 36 : 28))

                            TimerRing(fontSize: self.isIpad ? 96 : 48, remainingTime: String(textForPlaybackTime(time: TimeInterval(self.Game.timeRemaining))))

                        }.padding(.all)
                        VStack(spacing: 1) {
                            Text(self.blueTeamEmoji)
                                .font(Font.system(size: 48))
                                .frame(maxWidth: 64, maxHeight: 64, alignment: .center)
                                .modifier(ShakeEffect(shakes: self.Game.teamBlue * 2))
                                .if(self.Game.currentTeam == "blue") { $0.multicolorGlow(rotation: self.Game.teamBlue) }
                                .if(isPremium) { $0.contextMenu {
                                    Button(action: {
                                        self.blueTeamEmoji = "🚀"
                                        self.blueTeamName = "Roket Takımı"
                                    }) {
                                        Text("🚀 Roket Takımı")
                                    }
                                    Button(action: {
                                        self.blueTeamEmoji = "🐛"
                                        self.blueTeamName = "Böcekler"
                                    }) {
                                        Text("🐛 Böcekler")
                                    }
                                    Button(action: {
                                        self.blueTeamEmoji = "☠️"
                                        self.blueTeamName = "Killers"
                                    }) {
                                        Text("☠️ Killers")
                                    }
                                    Button(action: {
                                        self.blueTeamEmoji = "🦮"
                                        self.blueTeamName = "Köpek Burnu"
                                    }) {
                                        Text("🦮 Köpek Burnu")
                                    }
                                }
                                }

                            Text("\(self.Game.teamBlue)")
                                .foregroundColor(Color("MineShaft"))
                                //      .font(Font.system(size: self.isIpad ? 64 : 32, design: .monospaced))
                                .font(.custom("monogramextended", size: self.isIpad ? 72 : 48))
                                .fontWeight(.bold)
                        }
                    }
                    
                    
                } else {
                    
                    if swipeCounter > self.fetcher.words.count - 1 && isPremium == false {
                        Button(action: {
                            generator.impactOccurred()
                        }) {
                            HStack(alignment: .center) {
                                Text("🥳")
                                    .font(.system(size: 40))
                                    .modifier(ShakeEffect(shakes: 4 * 2))
                                VStack(alignment: .leading) {
                                    Text("Daha fazla eğlence!")
                                        .font(.custom("monogramextended", size: 20))
                                        .fontWeight(.bold)
                                    Text("Her hafta güncellenen +1500 yeni kelime...\nSatın almak için dokun.")
                                        .font(.custom("monogramextended", size: 16))
                                }
                            }
                            .padding(25)
                            .background(Color("Ebony"))
                            .cornerRadius(80)
                            .frame(width: 300, height: 160)
                            
                        }.multicolorGlow(rotation: 120)
                        
                        .transition(AnyTransition.asymmetric(insertion: .move(edge: .bottom), removal: .move(edge: .bottom)).combined(with: .opacity))
                        .buttonStyle(NoBGButtonStyle())
                        
                        .modifier(ShakeEffect(shakes: self.Game.teamRed * 2))
                        .frame(maxWidth: 600, maxHeight: 200, alignment: .center)
                    } else {
                        VStack(alignment: .center, spacing: 50) {
                            if self.Game.teamRed > self.Game.teamBlue {
                                VStack {
                                    Text("Tebrikler!")
                                        .foregroundColor(.black)
                                        .font(.custom("Kalam Bold", size: self.isIpad ? 96 : 32))
                                    
                                    Text("\(self.redTeamEmoji) \(self.redTeamName)")
                                        .foregroundColor(.black)
                                        .font(.custom("Kalam Bold", size: self.isIpad ? 96 : 32))
                                    confettiView
                                }
                                
                            } else if self.Game.teamRed == self.Game.teamBlue {
                                Text("Kazanan yok 🤷‍♂️")
                                    .foregroundColor(.black)
                                    .font(.custom("Kalam Bold", size: self.isIpad ? 96 : 32))
                            } else {
                                VStack {
                                    Text("Tebrikler")
                                        .foregroundColor(.black)
                                        .font(.custom("Kalam Bold", size: self.isIpad ? 96 : 32))
                                    Text("\(self.blueTeamEmoji) \(self.blueTeamName)")
                                        .foregroundColor(.black)
                                        .font(.custom("Kalam Bold", size: self.isIpad ? 96 : 32))
                                    confettiView
                                }
                            }
                            
                            Button(action: {
                                let level = UserDefaults.standard.optionalInt(forKey: "level") ?? 1
                                if isPremium {
                                    self.fetcher.words = self.fetcher.words.filter { $0.level == level }.shuffled()
                                }
                                self.Game.timeRemaining = self.Game.fulltime
                                self.Game.round = UserDefaults.standard.optionalInt(forKey: "round") ?? 5
                                self.Game.teamBlue = 0
                                self.Game.teamRed = 0
                                self.TheSoundManager.newGame()
                                self.Game.ended = false
                                self.Game.isActive = false
                                self.refresh()
                            }) {
                                VStack {
                                    Text("Yeni oyun için dokun")
                                        .foregroundColor(.black)
                                        .font(.custom("Kalam Bold", size: self.isIpad ? 32 : 22))
                                }
                                
                            }.transition(AnyTransition.asymmetric(insertion: .move(edge: .bottom), removal: .move(edge: .bottom)).combined(with: .opacity))
                        }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center)
                    }
                    
                  
                }

                if self.Game.isActive == true {
                    CardStack(direction: LeftRight.direction, data: self.fetcher.words, id: \Word.id, onSwipe: { _, direction in
                        //  print("Swiped \(word.word ?? "No word") to \(direction)")
                        //  print(direction)
                        let impactMed = UINotificationFeedbackGenerator()
                        self.swipeCounter += 1
                        if direction == .left {
                            self.isWrong = true
                            self.isRight = false
                            self.TheSoundManager.wrong()
                            // impactMed.notificationOccurred(.warning)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                withAnimation(.easeInOut) {
                                    self.isWrong = false
                                }
                            }
                        } else if direction == .right {
                            self.isWrong = false
                            self.isRight = true
                            self.TheSoundManager.right()

                            impactMed.notificationOccurred(.success)

                            if self.Game.currentTeam == "red" {
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
                    }, content: { word, direction, _ in
                        SingleWordItem(item: word, isIpad: self.isIpad, swipeCount: self.swipeCounter, count: self.fetcher.words.count, direction: direction)
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

                } else {
                    Button(action: {
                        generator.impactOccurred()
                        self.Game.timeRemaining = self.Game.fulltime
                        let level = UserDefaults.standard.optionalInt(forKey: "level") ?? 1
                        if isPremium {
                            self.fetcher.words = self.fetcher.words.filter { $0.level == level }.shuffled()
                        } else {
                            self.fetcher.words = self.fetcher.words
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now()) {
                            withAnimation(.interpolatingSpring(mass: 1.0,
                                                               stiffness: 100.0,
                                                               damping: 10,
                                                               initialVelocity: 0)) {
                                self.Game.isActive = true
                                self.TheSoundManager.nextRound()
                                if self.Game.currentTeam == "red" {
                                    self.Game.currentTeam = "blue"
                                    currentTeamName = "blue"
                                } else if self.Game.currentTeam == "blue" {
                                    self.Game.currentTeam = "red"
                                    currentTeamName = "red"
                                }
                            }
                        }
                    }) {
                        if self.Game.ended == false && self.Game.round > 0 {
                            HStack(alignment: .center) {
                                if self.Game.currentTeam == "red" {
                                    Text("\(self.blueTeamEmoji)")
                                        .font(.system(size: 40))
                                        .modifier(ShakeEffect(shakes: 4 * 2))

                                } else {
                                    Text("\(self.redTeamEmoji)")
                                        .font(.system(size: 40))
                                        .modifier(ShakeEffect(shakes: 4 * 2))
                                }
                                VStack(alignment: .leading) {
                                    if self.Game.currentTeam == "red" {
                                        Text(" \(self.blueTeamName) oynuyor")
                                            .font(.custom("monogramextended", size: 20))
                                            .fontWeight(.bold)
                                    } else {
                                        Text(" \(self.redTeamName) oynuyor")
                                            .font(.custom("monogramextended", size: 20))
                                            .fontWeight(.bold)
                                    }
                                    Text("Başlamak için buraya dokun")
                                        .font(.custom("monogramextended", size: 16))
                                }
                            }
                            .padding(25)
                            .background(Color("Ebony"))
                            .cornerRadius(80)
                            .frame(width: 300, height: 160)
                            .shadow(color: Color("Ebony").opacity(0.6), radius: 20, x: 0, y: 20)
                        }
                    }
                    .transition(AnyTransition.asymmetric(insertion: .move(edge: .bottom), removal: .move(edge: .bottom)).combined(with: .opacity))
                    .buttonStyle(NoBGButtonStyle())
                    .frame(maxWidth: 600, maxHeight: 200, alignment: .center)
                }
            }
            .onReceive(timer) { _ in
                guard self.Game.isActive else { return }
                if self.Game.timeRemaining > 0 {
                    self.Game.timeRemaining -= 1
                }

                if self.Game.round > 0 {
                    if self.Game.timeRemaining <= 1 {
                        DispatchQueue.main.asyncAfter(deadline: .now()) {
                            withAnimation(.interpolatingSpring(mass: 1.0,
                                                               stiffness: 100.0,
                                                               damping: 10,
                                                               initialVelocity: 0)) {
                                generator.impactOccurred()
                                self.Game.isActive = false
                                self.Game.timeRemaining = UserDefaults.standard.integer(forKey: "time")
                            }
                        }

                        withAnimation(.easeInOut) {
                            self.Game.isActive = false
                        }

                        if self.removeRound == true {
                            self.Game.round -= 1
                            self.removeRound.toggle()
                        } else {
                            self.removeRound.toggle()
                        }
                    }
                } else if self.Game.round <= 1 {
                    generator.impactOccurred()
                    withAnimation(.easeInOut) {
                        self.TheSoundManager.endGame()
                        self.Game.ended = true
                        self.Game.isActive = false
                    }
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
                // self.Game.isActive = false
                settings.set(self.Game.currentTeam, forKey: "currentTeam")
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                //  self.Game.isActive = true
                self.Game.currentTeam = UserDefaults.standard.string(forKey: "currentTeam") ?? "blue"
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center)
            .popup(isPresented: self.$showPromotion, type: .default, position: .top, animation: Animation.spring(), autohideIn: 22) {
                HStack(spacing: 15) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Ever thought of taking a break?")
                            .foregroundColor(.black)
                            .fontWeight(.bold)

                        Text("Our hand picked organic fresh tasty coffee from southern slopes of Australia is bound to lighten your mood.")
                            .font(.system(size: 14))
                            .foregroundColor(.black)
                    }
                }
                .padding(15)
                .frame(width: 300, height: 160)

                .cornerRadius(20.0)
            }
        }

        .onAppear {
            StoreReviewHelper.incrementAppOpenedCount()
            StoreReviewHelper.checkAndAskForReview()

            if isPremium {
                self.fetcher.getPremiumWords()
            } else {
                self.fetcher.getFreeWords()
            }
        }
        .background(
            Image("MainBGImage")
                .resizable()
                .frame(maxWidth: .infinity, maxHeight: .infinity))
        .edgesIgnoringSafeArea(.all)
        .sheet(isPresented: self.$isSettingsOpen, onDismiss: {
            self.refresh()
        }) {
            Settings()
        }
    }
}
