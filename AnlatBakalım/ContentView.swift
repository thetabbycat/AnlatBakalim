
import StoreKit
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

        fetcher.getFreeWords()
    }

    func refresh() {
        Game.teamBlue = 0
        Game.teamRed = 0
        Game.ended = false
        Game.isActive = false
        Game.timeRemaining = UserDefaults.standard.integer(forKey: "time")
        Game.fulltime = UserDefaults.standard.integer(forKey: "time")
        Game.round = UserDefaults.standard.optionalInt(forKey: "round") ?? 5
        Game.currentTeam = "blue"
        TheSoundManager.newGame()
    }

    let randPromo = promotText.randomElement()

    let webURL = URL(string: "https://apps.apple.com/us/app/anlat-bakal%C4%B1m/id1526011547")!

    var body: some View {
        ZStack {
            PromotionBanner(onTap: {
                generator.impactOccurred()
                UIApplication.shared.open(webURL)
                Game.ended = false
                Game.isActive = false
            }, isIpad: self.isIpad, item: self.randPromo!)

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
                                  isIpad: self.isIpad,
                                  onPurchase: {
                                      generator.impactOccurred()
                                      Game.ended = false
                                      Game.isActive = false
                                  },
                                  onReStart: { self.refresh() })
                }

                if self.Game.isActive == true {
                    CardStackView(wordStack: self.fetcher.words, onSwipeAction: { direction in
                        let impactMed = UINotificationFeedbackGenerator()
                        self.swipeCounter += 1
                        self.fetcher.words = self.fetcher.fetchLocalUsers().filter { $0.level == level }
                        
                        if self.swipeCounter == self.fetcher.words.count - 2  {
                            if #available(iOS 14.0, *) {
                                self.show()
                            } else {
                                // Fallback on earlier versions
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

                        if level == 2 {
                            self.fetcher.words = self.fetcher.fetchLocalUsers().filter { $0.level == 1 } + self.fetcher.fetchLocalUsers().filter { $0.level == 2 }
                            self.fetcher.words = self.fetcher.words.shuffled()
                        } else if level == 3 {
                            self.fetcher.words = self.fetcher.fetchLocalUsers().filter { $0.level == 2 }.shuffled()
                        } else {
                            self.fetcher.words = self.fetcher.fetchLocalUsers().filter { $0.level == 1 }.shuffled()
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

            fetcher.words = fetcher.fetchLocalUsers().filter { $0.level == level }.shuffled()
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

    @available(iOS 14.0, *)
    public func show() {
        DispatchQueue.main.async(execute: {
            let scene = UIApplication.shared
                .connectedScenes
                .filter { $0.activationState == .foregroundActive }
                .first

            let config = SKOverlay.AppConfiguration(appIdentifier: "1526011547", position: .bottomRaised)
            let overlay = SKOverlay(configuration: config)
            overlay.present(in: scene as! UIWindowScene)

        })
    }

    func gameLogic() {
        guard Game.isActive else { return }
        if Game.timeRemaining > 0 {
            Game.timeRemaining -= 1
        }
        


        if Game.round > 0 {
            if Game.timeRemaining <= 1 {
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

                if removeRound == true {
                    Game.round -= 1
                    removeRound.toggle()
                } else {
                    removeRound.toggle()
                }
            }
        } else if Game.round <= 1 {
            generator.impactOccurred()
            withAnimation(.easeInOut) {
                self.TheSoundManager.endGame()
                self.Game.ended = true
                self.Game.isActive = false
            }
        }
    }
}
