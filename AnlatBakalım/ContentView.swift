
import SwiftUI
import UIKit
import Purchases

let settings = UserDefaults.standard
let screen = UIScreen.main.bounds
let reachability = try! Reachability()

struct ContentView: View {
    @ObservedObject var fetcher = Fetcher()
    @ObservedObject var Game = GameManager()
    @ObservedObject var TheSoundManager = SoundManager()
    @ObservedObject var subscriptionManager = SubscriptionManager()

    var isIpad = UIDevice.current.model.hasPrefix("iPad")
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    let level = UserDefaults.standard.optionalInt(forKey: "level") ?? 1
    let generator = UIImpactFeedbackGenerator(style: .heavy)

    @State private var isActive = true
    @State private var removeRound = false
    @State private var isWrong = false
    @State private var isRight = false
    @State private var isSettingsOpen = false

    @State var redTeamEmoji = "🥑"
    @State var blueTeamEmoji = "🚀"
    @State var redTeamName = "Avokadolar"
    @State var blueTeamName = "Roket Takımı"
    @State var currentTeamName: String = UserDefaults.standard.string(forKey: "currentTeam") ?? "blue"

    @State var swipeCounter = 0

    @State var isPremium = UserDefaults.standard.optionalBool(forKey: "isSubscribed") ?? false
    // var isPremium = false

    init() {
        /**
         do {
         try reachability.startNotifier()
         } catch {
         print("Unable to start notifier")
         }
         reachability.whenUnreachable = { _ in
         print("no connection")
         }
         */

        UIApplication.shared.isIdleTimerDisabled = true
   
    }

    func refresh() {
        Game.teamBlue = 0
        Game.teamRed = 0
        Game.ended = false
        Game.isActive = false
        fetcher.words = fetcher.fetchLocalUsers().filter { $0.level == level }.shuffled()
        Game.timeRemaining = UserDefaults.standard.integer(forKey: "time")
        Game.fulltime = UserDefaults.standard.integer(forKey: "time")
        Game.round = UserDefaults.standard.optionalInt(forKey: "round") ?? 5
        Game.currentTeam = "blue"
        TheSoundManager.newGame()
    }
   

    var body: some View {
        ZStack {
            if self.swipeCounter > self.fetcher.words.count - 1 && self.Game.isActive == true && self.isPremium == false {
                PromotionButton(onTap: {
                    generator.impactOccurred()
                    self.subscriptionManager.buttonAction(purchase: subscriptionManager.lifetime!)
                    self.refresh()
                })
            }

            SettingsButton(onTap: { generator.impactOccurred()
                self.isSettingsOpen.toggle()
                self.TheSoundManager.menu()
            }, isIpad: self.isIpad)

            TrueOrFalseIcons(isWrong: self.isWrong, isRight: self.isRight)

            VStack {
                if self.Game.ended == false && self.Game.round >= 1 {
                    HeaderView(redTeamEmoji: $redTeamEmoji,
                               blueTeamEmoji: $blueTeamEmoji,
                               redTeamName: $redTeamName,
                               blueTeamName: $blueTeamName,
                               teamRed: self.Game.teamRed,
                               teamBlue: self.Game.teamBlue,
                               isPremium: self.isPremium,
                               isIpad: self.isIpad,
                               round: self.Game.round,
                               timeRemaining: self.Game.timeRemaining
                    )

                } else {
                    GameEndedView(redTeamEmoji: $redTeamEmoji,
                                  blueTeamEmoji: $blueTeamEmoji,
                                  redTeamName: $redTeamName,
                                  blueTeamName: $blueTeamName,
                                  teamRed: self.Game.teamRed,
                                  teamBlue: self.Game.teamBlue,
                                  isPremium: self.isPremium,
                                  isIpad: self.isIpad,
                                  onPurchase: {
                                      generator.impactOccurred()
                                      self.subscriptionManager.buttonAction(purchase: subscriptionManager.lifetime!)
                                      self.refresh()
                                  },
                                  onReStart: { self.refresh() })
                }

                if self.Game.isActive == true {
                    CardStackView(wordStack: self.fetcher.words, onSwipeAction: { direction in
                        let impactMed = UINotificationFeedbackGenerator()
                        self.swipeCounter += 1
                        if self.swipeCounter == self.fetcher.words.count - 1 {
                            if isPremium {
                                self.fetcher.words = self.fetcher.fetchLocalUsers().filter { $0.level == level }.shuffled()
                            } else {
                                self.fetcher.words = self.fetcher.fetchLocalUsers().filter { $0.level == level }
                            }
                        }
                        
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
                    }, isIpad: self.isIpad, swipeCounter: self.swipeCounter)

                } else {
                    PlayButton(onTap: {
                        generator.impactOccurred()
                        self.Game.timeRemaining = self.Game.fulltime
                        let level = UserDefaults.standard.optionalInt(forKey: "level") ?? 1
                        if isPremium {
                            self.fetcher.words = self.fetcher.fetchLocalUsers().filter { $0.level == level }.shuffled()
                        } else {
                            self.fetcher.words = self.fetcher.fetchLocalUsers().filter { $0.level == level }
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
                    }, ended: self.Game.ended,
                    round: self.Game.round,
                    currentTeam: self.Game.currentTeam,
                    redTeamEmoji: self.redTeamEmoji,
                    blueTeamEmoji: self.blueTeamEmoji,
                    redTeamName: self.redTeamName,
                    blueTeamName: self.blueTeamName
                    )
                }
            }
            .onReceive(timer) { _ in
                self.gameLogic()
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
                settings.set(self.Game.currentTeam, forKey: "currentTeam")
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                self.Game.currentTeam = UserDefaults.standard.string(forKey: "currentTeam") ?? "blue"
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center)
        }
        .onAppear {
            StoreReviewHelper.incrementAppOpenedCount()
            StoreReviewHelper.checkAndAskForReview()
        }
        .background(
            Image("MainBGImage")
                .resizable()
                .frame(maxWidth: .infinity, maxHeight: .infinity))
        .edgesIgnoringSafeArea(.all)
        
        .sheet(isPresented: self.$isSettingsOpen, onDismiss: {
            self.refresh()
        }) {
            SettingsView()
        }
    }
    
    func gameLogic() {
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
    
}
