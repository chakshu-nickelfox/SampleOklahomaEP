//
//  Chapter.swift
//  Oklahoma
//
//  Created by Chakshu Dawara on 26/12/23.
//

import Foundation
import RealmSwift


class Chapter: Object {
    
    @objc dynamic var chapterId = -1
    @objc dynamic var chapterName = ""
    @objc dynamic var questionCount = -1
    @objc dynamic var score = 0
    @objc dynamic var correctAttempts = 0
    @objc dynamic var incorrectAttempts = 0
    let practiceQuestions = List<PracticeQuestion>()
    @objc dynamic public var purchaseState = 0
    @objc var studyDeckQuestions = 0
    
    override static func primaryKey() -> String? {
        return "chapterId"
    }
    
}
