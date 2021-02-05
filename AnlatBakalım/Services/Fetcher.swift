//
//  Fetcher.swift
//  AnlatBakalim
//
//  Created by Steven J. Selcuk on 8.05.2020.
//  Copyright © 2020 Steven J. Selcuk. All rights reserved.
//

import Alamofire
import CoreData
import SwiftyJSON
import Sync

class Fetcher: ObservableObject {
    private let dataStack: DataStack
    @Published var words = [Word]()
    private var isPremium = UserDefaults.standard.optionalBool(forKey: "isPremium") ?? false
    private var lastWordPoolVersion = UserDefaults.standard.string(forKey: "version") ?? "No"
    @Published var poolVersion: String = "v1.0.0"
    @Published var needVersionUpdated: Bool = true
    @Published var updateReady: Bool = false

    init() {
        dataStack = DataStack(modelName: "AnlatBakalim")
        self.words = fetchLocalUsers().shuffled()
    }

    func fetchLocalUsers() -> [Word] {
        let request: NSFetchRequest<Word> = Word.fetchRequest()

        return try! dataStack.viewContext.fetch(request)
    }

    func deleteAllData(entity: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Word")
        fetchRequest.returnsObjectsAsFaults = false

        do {
            let arrUsrObj = try managedContext.fetch(fetchRequest)
            for usrObj in arrUsrObj as! [NSManagedObject] {
                managedContext.delete(usrObj)
            }
            try managedContext.save() // don't forget
        } catch let error as NSError {
            print("delete fail--", error)
        }
    }

    func syncUsingAlamofire(completion: @escaping (_ result: VoidResult) -> Void) {
        Alamofire.request("https://tabbythecat.com/__/anlatbakalim/premium", encoding: JSONEncoding.default).responseData { response in

            guard let data = response.data else { return }
            let json = try? JSON(data: data)
            let theWords = json?["data"].arrayObject

            if let _ = response.value, let wordsJSON = theWords as? [[String: Any]] {
                self.dataStack.sync(wordsJSON, inEntityNamed: "Word") { _ in
                    self.words = self.fetchLocalUsers().shuffled()
                    completion(.success)
                }
            } else if let error = response.error {
                completion(.failure(error as NSError))
            } else {
                fatalError("No error, no failure")
            }
        }
    }

    func checkVersion(completion: @escaping (_ result: VoidResult) -> Void) {
    }

    func syncUsingLocalJSON(completion: @escaping (_ result: VoidResult) -> Void) {
        guard let url = URL(string: "words.json") else { return }
        guard let filePath = Bundle.main.path(forResource: url.deletingPathExtension().absoluteString, ofType: url.pathExtension) else { return }
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: filePath)) else { return }
        guard let json = try! JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] else { return }

        dataStack.sync(json, inEntityNamed: "Word") { _ in
            completion(.success)
        }
    }

    func getFreeWords() {
        syncUsingLocalJSON { [self] result in
            switch result {
            case .success:
                self.words = fetchLocalUsers()
                print("Local Sync ok.")
            case let .failure(error):
                print(error)
            }
        }
    }

    func getPremiumWords() {
        syncUsingAlamofire { [self] result in
            switch result {
            case .success:
                self.words = fetchLocalUsers().shuffled()
                print("Server sync done.")
            case let .failure(error):
                print(error)
            }
        }
    }

    func getVersion() {
        guard needVersionUpdated else {
            checkVersion { result in
                switch result {
                case .success:
                    self.needVersionUpdated = false
                    print("Version checked.")
                case let .failure(error):
                    print(error)
                    self.needVersionUpdated = true
                }
            }
            return
        }
    }
}

enum VoidResult {
    case success
    case failure(NSError)
}

extension String {
    var parseJSONString: AnyObject? {
        let data = self.data(using: String.Encoding.utf8, allowLossyConversion: false)

        if let jsonData = data {
            // Will return an object or nil if JSON decoding fails
            return try! JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject
        } else {
            // Lossless conversion of the string was not possible
            return nil
        }
    }
}
