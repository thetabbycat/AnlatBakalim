
import CardStack
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

    @State var reloadToken = UUID()
    @State private var isActive = true
    @State private var removeRound = false
    @State private var isWrong = false
    @State private var isRight = false
    @State private var isSettingsOpen = false

    @State var redTeamEmoji = "🥑"
    @State var blueTeamEmoji = "🚀"
    @State var redTeamName = "Avokadolar"
    @State var blueTeamName = "Roket Takımı"

    init() {
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
        reachability.whenUnreachable = { _ in
            print("no connection")
        }
    }

    func refresh() {
        reloadToken = UUID()
        fetcher.words = fetcher.fetchLocalUsers()
        Game.fulltime = UserDefaults.standard.integer(forKey: "time")
        Game.timeRemaining = UserDefaults.standard.integer(forKey: "time")
        Game.round = UserDefaults.standard.optionalInt(forKey: "round") ?? 5
        TheSoundManager.menu()
        Game.ended = false
        Game.isActive = false
    }

    func refreshFullTime(time: Int) {
        settings.set(time, forKey: "time")
        reloadToken = UUID()
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
                        .frame(maxWidth: isIpad ? 64 : 48, maxHeight: isIpad ? 64 : 48, alignment: .center)
                }
            }
            .buttonStyle(MyButtonStyle())
            .offset(x: self.isIpad ? screen.width / 2 - 70 : screen.width / 2 - 45, y: -(screen.height / 2 - 80))
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
                            VStack {
                                Text(self.redTeamEmoji)
                                    .font(Font.system(size: 48))
                                    .transition(AnyTransition.asymmetric(insertion: .scale, removal: .scale).combined(with: .opacity))
                                    .frame(maxWidth: 64, maxHeight: 64, alignment: .center)
                            }
                            .contextMenu {
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
                            }

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
                            VStack {
                                Text(self.blueTeamEmoji)
                                    .font(Font.system(size: 48))
                                    .transition(AnyTransition.asymmetric(insertion: .scale, removal: .scale).combined(with: .opacity))
                                    .frame(maxWidth: 64, maxHeight: 64, alignment: .center)
                            }

                            .contextMenu {
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
                            Text("\(self.Game.teamBlue)")
                                .foregroundColor(Color("MineShaft"))
                                //      .font(Font.system(size: self.isIpad ? 64 : 32, design: .monospaced))
                                .font(.custom("monogramextended", size: self.isIpad ? 72 : 48))
                                .fontWeight(.bold)
                                .transition(AnyTransition.asymmetric(insertion: .scale, removal: .scale).combined(with: .opacity))
                        }
                    }
                } else {
                    Button(action: {
                        let level = UserDefaults.standard.optionalInt(forKey: "level") ?? 1
                        self.reloadToken = UUID()
                        self.fetcher.words = self.fetcher.words.filter { $0.level == level }.shuffled()
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
                            if self.Game.teamRed > self.Game.teamBlue {
                                Text("Tebrikler! \(self.redTeamEmoji) \(self.redTeamName)")
                                    .foregroundColor(.black)
                                    .font(.custom("Kalam Bold", size: self.isIpad ? 96 : 32))
                            } else if self.Game.teamRed == self.Game.teamBlue {
                                Text("Kazanan yok 🤷‍♂️")
                                    .foregroundColor(.black)
                                    .font(.custom("Kalam Bold", size: self.isIpad ? 96 : 32))
                            } else {
                                Text("Tebrikler!  \(self.blueTeamEmoji) \(self.blueTeamName)")
                                    .foregroundColor(.black)
                                    .font(.custom("Kalam Bold", size: self.isIpad ? 96 : 32))
                            }
                            Text("Tekrar oynamak için dokun")
                                .foregroundColor(.black)
                                .font(.custom("Kalam Bold", size: self.isIpad ? 32 : 22))
                        }
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center)

                    }.transition(AnyTransition.asymmetric(insertion: .move(edge: .bottom), removal: .move(edge: .bottom)).combined(with: .opacity))
                }

                if self.Game.isActive == true {
                    CardStack(direction: LeftRight.direction, data: self.fetcher.words, id: \Word.id, onSwipe: { _, direction in
                        //  print("Swiped \(word.word ?? "No word") to \(direction)")
                        //  print(direction)
                        if direction == .left {
                            self.isWrong = true
                            self.isRight = false
                            self.TheSoundManager.wrong()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                withAnimation(.easeInOut) {
                                    self.isWrong = false
                                }
                            }
                        } else if direction == .right {
                            self.isWrong = false
                            self.isRight = true
                            self.TheSoundManager.right()
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
                        SingleWordItem(item: word, isIpad: self.isIpad, direction: direction)
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
                        self.Game.timeRemaining = self.Game.fulltime
                        let level = UserDefaults.standard.optionalInt(forKey: "level") ?? 1
                        self.fetcher.words = self.fetcher.words.filter { $0.level == level }.shuffled()
                        DispatchQueue.main.asyncAfter(deadline: .now()) {
                            withAnimation(.interpolatingSpring(mass: 1.0,
                                                               stiffness: 100.0,
                                                               damping: 10,
                                                               initialVelocity: 0)) {
                                self.Game.isActive = true
                                self.TheSoundManager.nextRound()
                                if self.Game.currentTeam == "red" {
                                    self.Game.currentTeam = "blue"
                                } else if self.Game.currentTeam == "blue" {
                                    self.Game.currentTeam = "red"
                                }
                            }
                        }
                    }) {
                        if self.Game.ended == false && self.Game.round > 0 {
                            if self.Game.currentTeam == "red" {
                                VStack {
                                    Text(" \(self.blueTeamEmoji) \(self.blueTeamName)")
                                        .foregroundColor(Color("MineShaft"))
                                        .font(.custom("Kalam Bold", size: self.isIpad ? 32 : 28))
                                    Text("oynuyor. Başlamak için dokun")
                                        .foregroundColor(Color("MineShaft"))
                                        .font(.custom("Kalam Bold", size: self.isIpad ? 22 : 12))
                                }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center)

                            } else if self.Game.currentTeam == "blue" {
                                VStack {
                                    Text("\(self.redTeamEmoji) \(self.redTeamName)")
                                        .foregroundColor(Color("MineShaft"))
                                        .font(.custom("Kalam Bold", size: self.isIpad ? 22 : 28))
                                    Text("oynuyor. Başlamak için dokun")
                                        .foregroundColor(Color("MineShaft"))
                                        .font(.custom("Kalam Bold", size: self.isIpad ? 22 : 12))
                                }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center)
                            }
                        }
                    }
                    .transition(AnyTransition.asymmetric(insertion: .move(edge: .bottom), removal: .move(edge: .bottom)).combined(with: .opacity))
                    .buttonStyle(GoodButtonStyle())
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
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center)
        }
        .onAppear {
            StoreReviewHelper.incrementAppOpenedCount()
            StoreReviewHelper.checkAndAskForReview()

            reachability.whenReachable = { reachability in
                if reachability.connection == .wifi {
                    self.fetcher.getPremiumWords()
                } else {
                    self.fetcher.getPremiumWords()
                }
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
