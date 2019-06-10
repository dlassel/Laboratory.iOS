//
//  LabCollectionVM.swift
//  Laboratory
//
//  Created by Administrator on 5/7/19.
//  Copyright © 2019 2Letters. All rights reserved.
//

import Foundation
import FirebaseFirestore

// For Lab List ViewController
class LabCollectionVM {
    var allLabVMs: [LabCellVM]?
    var displayingLabVMs: [LabCellVM]?
    
    func getLabId(at index: Int) -> String {
        return displayingLabVMs![index].labId
    }
    
    func fetchLabData(completion: @escaping FetchFirestoreHandler) {
         Firestore.firestore().collection("users").document("uY4N6WXX7Ij9syuL5Eb6").collection("labs").order(by: "labName", descending: false).getDocuments { [weak self] (snapshot, error) in
            guard let self = self else { return }
            if error != nil {
                completion(.failure(error?.localizedDescription ?? "ERR fetching Labs data"))
            } else {
                var labVMs = [LabCellVM]()
                for document in (snapshot!.documents) {
                    if let labName = document.data()["labName"] as? String,
                    let description = document.data()["description"] as? String {
                        labVMs.append(LabCellVM(lab: Lab(id: document.documentID, name: labName, description: description)))
                    }
                }
                self.allLabVMs = labVMs
                self.displayingLabVMs = labVMs
                completion(.success)
            }
        }
    }
    
    func search(by text: String) {
        if text == "" {
            displayingLabVMs = allLabVMs
        } else {
            displayingLabVMs = allLabVMs?.filter({$0.labName.lowercased().contains(text.lowercased())})
        }
    }
}