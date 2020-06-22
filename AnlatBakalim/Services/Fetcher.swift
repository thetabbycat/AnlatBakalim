//
//  Fetcher.swift
//  AnlatBakalim
//
//  Created by Steven J. Selcuk on 8.05.2020.
//  Copyright © 2020 Steven J. Selcuk. All rights reserved.
//

import CoreData
import Sync
import Alamofire


class Fetcher: ObservableObject {
    private let dataStack: DataStack
    @Published var words = [Word]()
    
    
    init() {
        self.dataStack = DataStack(modelName: "AnlatBakalim")
        self.words = fetchLocalUsers()
    }
    
   func fetchLocalUsers() -> [Word] {
        let request: NSFetchRequest<Word> = Word.fetchRequest()
        
        return try! self.dataStack.viewContext.fetch(request)
    }
    
    
    func syncUsingAlamofire(completion: @escaping (_ result: VoidResult) -> ()) {
        AF.request("https://anlatbakalim.tabbycat.workers.dev").responseJSON { response in
            if let jsonObject = response.value, let wordsJSON = jsonObject as? [[String: Any]] {
                self.dataStack.sync(wordsJSON, inEntityNamed: "Word") { error in
                    print(wordsJSON)
                    completion(.success)
                }
            } else if let error = response.error {
                completion(.failure(error as NSError))
            } else {
                fatalError("No error, no failure")
            }
        }
    }
    
    func syncUsingLocalJSON(completion: @escaping (_ result: VoidResult) -> ()) {
        let fileName = "words.json"
        guard let url = URL(string: fileName) else { return }
        guard let filePath = Bundle.main.path(forResource: url.deletingPathExtension().absoluteString, ofType: url.pathExtension) else { return }
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: filePath)) else { return }
        guard let json = try! JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] else { return }
        
        self.dataStack.sync(json, inEntityNamed: "Word") { error in
            completion(.success)
        }
    }
    
    func getLocalWords() {
        self.syncUsingLocalJSON { result in
            switch result {
                case .success:
                    print("Sync ok.")
                case .failure(let error):
                    print(error)
            }
        }
    }
    
    func refresh() {
        self.syncUsingAlamofire { result in
            switch result {
                case .success:
                    print("Sync ok.")
                case .failure(let error):
                    print(error)
            }
        }
    }
}

enum VoidResult {
    case success
    case failure(NSError)
}
