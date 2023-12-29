//
//  PracticeQuestion.swift
//  Oklahoma
//
//  Created by Chakshu Dawara on 26/12/23.
//

import Foundation
import RealmSwift

public class PracticeQuestion: Object {
    @objc dynamic var id: Int = 0
    @objc dynamic var chapterID = 0
    @objc dynamic var chapterName = ""
    @objc dynamic var questionId = ""
    @objc dynamic var questionText = ""
    @objc dynamic var optionA = ""
    @objc dynamic var optionB = ""
    @objc dynamic var optionC = ""
    @objc dynamic var optionD = ""
    @objc dynamic var correctAnswer = ""
    @objc dynamic var referencePage = ""
    @objc dynamic var questionImage = ""
    @objc dynamic var questionType = ""
    @objc dynamic var inStudyDeck = false
    @objc dynamic var didAnswerCorrect = false
    @objc var userAnswer = ""
    @objc var correctAnswerText = ""
    @objc dynamic var qID = ""
    
    public override class func primaryKey() -> String? {
        return "qID"
    }
    
    // Increment id
    func incrementID() -> Int {
        var realm: Realm {
            do {
                return try Realm()
            } catch let error {
                fatalError("Error initializing Realm: \(error)")
            }
        }
        
        return (realm.objects(PracticeQuestion.self).max(ofProperty: "id") as Int? ?? 0)
    }
    
    // Inverse relationship
    let chapter = LinkingObjects(fromType: Chapter.self, property: "practiceQuestions")
    
}

extension PracticeQuestion {
    
    public func answeredOption(isCorrect: Bool) {
        do {
            let realm = try Realm()
            do {
                try realm.write {
                    self.didAnswerCorrect = isCorrect ? true : false
                }
            } catch {
                print(error)
            }
        } catch {
            print(error)
        }
    }
}
