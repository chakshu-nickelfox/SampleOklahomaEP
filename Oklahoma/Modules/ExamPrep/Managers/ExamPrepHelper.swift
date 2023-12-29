//
//  ExamPrepHelper.swift
//  Oklahoma
//
//  Created by Chakshu Dawara on 25/12/23.
//

import RealmSwift
import Foundation

class ExamPrepHelper: NSObject {
    
    @objc var eName: String = String()
    @objc var chapters = [Chapter]()
    @objc var questions = [PracticeQuestion]()
    @objc var currentQuestion = PracticeQuestion()
    @objc var questionsFlag = false
    var lastId = 0
    
    static func checkForChaptersInitialisation() {
        let userDefaults = UserDefaults.standard
        let isChaptersInitialized = userDefaults.bool(forKey: Constant.ExamPrep.initializedExamPrepChapters)
        let versionNumberKey = (userDefaults.value(forKey: Constant.ExamPrep.versionNumberKey) as? Float)
        let isVersionUpdated = (versionNumberKey != nil) &&
        (versionNumberKey != Constant.ExamPrep.versionNumber)
        
        
        if isVersionUpdated {
            UserDefaults.standard.set(Constant.ExamPrep.versionNumber, forKey: Constant.ExamPrep.versionNumberKey)
        } else {
            if !isChaptersInitialized {
                ExamPrepHelper().loadChapters(true)
            }
        }
    }
    
    private func loadChapters(_ reload: Bool) {
        guard let url = Bundle.main.url(forResource: "ExamPrepChapters", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            return
        }
        do {
            let realm = try Realm()
            let json = try JSONSerialization.jsonObject(with: data, options: [])
            
            if let chapters = json as? [[String: Any]] {
                // loop over list of json objects and write them to the database
                for var chapter in chapters {
                    do {
                        // fetch and add list of respective questions to the chapter
                        ExamPrepHelper.fetchPracticeQuestionsFor(chapter: &chapter)
                        try realm.write {
                            realm.create(Chapter.self, value: chapter, update: .modified)
                        }
                    } catch {
                        print(error)
                    }
                }
                let defaults = UserDefaults.standard
                defaults.set(true, forKey: Constant.ExamPrep.initializedExamPrepChapters)
                defaults.synchronize()
            }
        } catch {
            print(error)
        }
    }
    
    /// This method fetches the respective list of practice questions from the json and adds them to the passed chapter
    /// - Parameter chapter: mutable instance of json object, to which the list of practice questions is added
    static func fetchPracticeQuestionsFor(chapter: inout  [String: Any]) {
        // retrieve the respective json file using the passed chapter index
        guard let chapterIndex = chapter["chapterId"] as? Int,
              let url = Bundle.main.url(forResource: "ExamPrepChapter\(chapterIndex)", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            return
        }
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: [])
            
            if let jsonDict = json as? [String: Any],
               let quiz = jsonDict["quiz"] as? [String: Any],
               let questions = quiz["question"] as? [[String: Any]] {
                var updatedQuestions = [[String: Any]]()
                var quest = [String: Any]()
                for question in questions {
                    if let questionText = question["question"] as? String {
                     // qID 01-01
                        if let uniqueID = (question["_id"] as? String) {
                            quest["qID"] = uniqueID
                        }
                        quest["questionText"] = questionText
                        quest["correctAnswer"] = "\(question["correctAnswer"] as? Int ?? 0)"
                        quest["referencePage"] = question["refPage"] as? String
                        quest["chapterName"] = chapter["name"] as? String
                        
                        /// qID should exclude 0's: 14-1 not 14-01 or 1-1 not 01-01
                        if let qID = question["_id"] as? String {
                            let idComponents = qID.components(separatedBy: "-")
                            // id 30, question number with respect to the chapter
                            let questId = Int(idComponents[1])!
                            quest["id"] = questId
                            quest["questionId"] = "\(questId)"
                            let chapterID = Int(idComponents[0])!
                            quest["chapterID"] = chapterID
                        } else {
                            fatalError("something went wrong with the id Components!!!")
                        }
                        
                        quest["optionA"] = question["possible0"] as? String
                        quest["optionB"] = question["possible1"] as? String
                        quest["optionC"] = question["possible2"] as? String
                        quest["optionD"] = question["possible3"] as? String
                    }
                    /// Add current question to the array of question
                    updatedQuestions.append(quest)
                }
                /// Add Questions array into array of chapter
                chapter["practiceQuestions"] = updatedQuestions
            }
        } catch {
            print(error)
        }
    }
    
    private func deleteLocalChapters() {
        do {
            let realm = try Realm()
            let examprepChapters = realm.objects(Chapter.self)
            do {
                try realm.write {
                    realm.delete(examprepChapters)
                }
            } catch {
                print("Error occurred while writing to Realm")
            }
        } catch {
            print("Error occurred while opening Realm")
        }
    }
    
    static func getQuestionType(with type: String) -> QuestionType {
        switch type {
        case "ATTEMPTED": return .attempted
        case "UNATTEMPTED": return .unattempted
        default: return .unattempted
        }
    }
    
}
