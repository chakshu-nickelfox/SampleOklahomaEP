//
//  ExamManager.swift
//  Oklahoma
//
//  Created by Chakshu Dawara on 25/12/23.
//

import Foundation
import RealmSwift
import Realm

struct ExamManager {
    
    static var realm: Realm {
        do {
            return try Realm()
        } catch let error {
            fatalError("Error initializing Realm: \(error)")
        }
    }

    // get all chapters
    static func getAllChapters() -> [Chapter] {
        let chapters = realm.objects(Chapter.self).map { $0 }
        print("chapters count: ", chapters.count)
        return Array(chapters)
    }
    
    // get chapters in study deck
    static func getChaptersInStudyDesk() -> [PracticeQuestion] {
        let studyDeskChapters = realm.objects(PracticeQuestion.self).filter("inStudyDeck == true").sorted(byKeyPath: "chapterID")
        return Array(studyDeskChapters)
    }
    
    static func getAllQuestions() -> [PracticeQuestion] {
        var questions: [PracticeQuestion] = []
        let chapters = realm.objects(Chapter.self).map { $0 }
        for chapter in chapters {
            questions.append(contentsOf: chapter.practiceQuestions)
        }
        return questions
    }
    
    static func getQuestionBy(id qID: String) -> PracticeQuestion? {
        var requiredQuestion: PracticeQuestion?
        let chapters = realm.objects(Chapter.self).map { $0 }
        for chapter in chapters {
            for question in chapter.practiceQuestions where question.qID == qID {
                requiredQuestion = question
            }
        }
        return requiredQuestion
        
    }
    
    static func getStudyDeckCount(forChapter chapterId: Int) -> Int {
        let examQuestions = realm.objects(PracticeQuestion.self).filter("chapterID = %@ and inStudyDeck == true", chapterId)
        return examQuestions.count
    }
    
    static func getQuestionsForChapter(forChapter chapterId: Int) -> [PracticeQuestion] {
        var questions: [PracticeQuestion] = []
        let chapters = realm.objects(Chapter.self).map { $0 }
        for chapter in chapters where chapter.chapterId == chapterId {
            questions.append(contentsOf: chapter.practiceQuestions)
        }
        return questions
    }
    
    static func updateQuestion(chapterId: Int, qID: String, isCurrentAttempted: Bool, isAnswerCorrect: Bool, incorrectAnswer: String) throws {
        let localQuestion = realm.objects(PracticeQuestion.self)
            .filter("chapterID = %@ and qID = %@", chapterId, qID)
            .first
        
        do {
            realm.beginWrite()
            localQuestion!["questionType"] = isCurrentAttempted ? QuestionType.attempted.rawValue : QuestionType.unattempted.rawValue
            localQuestion!["didAnswerCorrect"] = isAnswerCorrect
            localQuestion!["userAnswer"] = incorrectAnswer
            try realm.commitWrite()
        } catch {
            print("Realm error while adding or removing question in the study deck.")
        }
    }
    
    // clear question in study deck
    
    static func clearStudyDesk() {
        let studyDeckQuestions = realm.objects(PracticeQuestion.self).filter("inStudyDeck == true")
        for practiceQuestion in studyDeckQuestions {
            do {
                try realm.write {
                    practiceQuestion["inStudyDeck"] = false
                }
            } catch {
                print("Realm Error while clearing study Deck")
            }
        }
        
    }
    
    static func addQuestionToStudyDesk(chapterId: Int, qID: String, addToStudyDeck: Bool) {
        let localQuestion = realm.objects(PracticeQuestion.self)
            .filter("chapterID = %@ and qID = %@", chapterId, qID).first
        do {
            realm.beginWrite()
            localQuestion!["inStudyDeck"] = addToStudyDeck
            try realm.commitWrite()
        } catch {  print("Realm error while adding or removing question in the study deck.") }
    }
    
    // clear reports
    
    static func clearTestResults() {
        let examPrepChapters = realm.objects(Chapter.self)
        do {
            try realm.write {
                for chapter in examPrepChapters {
                    chapter.correctAttempts = 0
                    chapter.incorrectAttempts = 0
                    chapter.score = 0
                    for questions in chapter.practiceQuestions {
                        questions.didAnswerCorrect = false
                        questions.questionType = QuestionType.unattempted.rawValue
                    }
                }
            }
        } catch {
            print("Realm Error")
        }
    }
    // generate report for the chapters
    
    static func generateReports() {
        do {
            let realm = try Realm()
            let examPrepChapters = realm.objects(Chapter.self) // .sorted("chapterId", ascending: false)
            for chapter in examPrepChapters {
                var percentage = 0.0
                let totalAttempts = chapter.practiceQuestions.count
                if totalAttempts == 0 {
                    percentage = 0
                } else {
                    let correctAnswers =  chapter.practiceQuestions.filter({ $0.didAnswerCorrect == true }).count
                    percentage = ((Double(correctAnswers * 100) / Double(totalAttempts)))
                }
                do {
                    realm.beginWrite()
                    chapter.score = Int(percentage)
                    try realm.commitWrite()
                } catch {
                    print("Realm Error")
                }
            }
        } catch {
            print("Realm Error")
        }
    }
    
    // check if report is available for any of the chapters
    static func reportAvailableForChapters() -> Bool {
        let examPrepChapters = realm.objects(Chapter.self)
        let allMatch = examPrepChapters.allSatisfy { $0.score == 0 }
        return !allMatch
    }
    
    static public func updateChapterPurchaseStatus() {
        do {
            let realm = try Realm()
            let examPrepChapters = realm.objects(Chapter.self)
            try realm.write {
                examPrepChapters.forEach { $0.purchaseState = PurchaseState.paid.rawValue }
                if !DataModel.shared.isExamPrepPurchased {
                    for chapter in examPrepChapters {
                        let state: PurchaseState = chapter.chapterId == 1 ? .paid : .notPaid
                        chapter.purchaseState = state.rawValue
                    }
                }
            }
        } catch {
            print(error)
        }
    }
}
