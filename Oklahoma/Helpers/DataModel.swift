//
//  DataModel.swift
//  Oklahoma
//
//  Created by Chakshu Dawara on 25/12/23.
//

import Foundation
import FoxAPIKit

public typealias ModelAnyError = AnyError

private struct UserDefaultConfigKey {
    static let audioBookPurchased = "isAudiobookContentUnlocked"
    static let audioBookLoaded = "AudioBookLoadedKey"
    static let videoLoaded = "VideoLoadedKey"
    static let examPrepPurchased = "isExamPrepContentUnlocked"
    static let examPrepLoaded = "ExamPrepLoadedKey"
    static let perQuestionAttempt = "PerQuestionAttempt"
    static let savedSpeed = "savedSpeedAudio"
    static let maximumQuestionsToAttempt = "MaximumQuestionsToAttempt"
    static let enableStudyDeckForIncorrectAnswers = "enableStudyDeckForIncorrectAnswers"
    static let enableImmediateFeedbackForAnswers = "enableImmediateFeedbackForAnswers"
    static let videosPurchased = "VideosPurchasedKey"
    static let coursesPurchased = "isCoursesContentUnlocked"
    static let lastPlayedVideosIdentifiers = "LastPlayedVideosIdentifiers"
    static let resultTotalQuestions = "ResultTotalQuestions"
    static let resultCorrectQuestions = "ResultCorrectQuestions"
    static let resultIncorrectQuestions = "ResultIncorrectQuestions"
    static let courseloaded = "CourseLoadedKey"
    static let resultPercentage = "resultPercentage"
    static let returningUser = "returningUser"
    static let appLaunchedEarlier = "AppLaunchedEarlierKey"
}

public class DataModel {
    
    public static let shared = DataModel()
 //   public var examSettings = ExamSettings()

    @UserDefault(UserDefaultConfigKey.audioBookPurchased, false)
    public var isAudioBookPurchased: Bool
    
    @UserDefault(UserDefaultConfigKey.audioBookLoaded, false)
    public var isAudioBookLoaded: Bool
    
    @UserDefault(UserDefaultConfigKey.courseloaded, false)
    public var isCoursesLoaded: Bool
    
    @UserDefault(UserDefaultConfigKey.examPrepPurchased, false)
    public var isExamPrepPurchased: Bool
    
    @UserDefault(UserDefaultConfigKey.examPrepLoaded, false)
    public var isExamPrepLoaded: Bool

    @UserDefault(UserDefaultConfigKey.perQuestionAttempt, 1)
    public var perQuestionAttempt: Int
    
    @UserDefault(UserDefaultConfigKey.savedSpeed, 1.0)
    public var savedSpeed: Float
    
    @UserDefault(UserDefaultConfigKey.maximumQuestionsToAttempt, 1)
    public var maximumQuestionsToAttempt: Int
    
    @UserDefault(UserDefaultConfigKey.enableStudyDeckForIncorrectAnswers, true)
    public var enableStudyDeckForIncorrectAnswers: Bool
    
    @UserDefault(UserDefaultConfigKey.enableImmediateFeedbackForAnswers, true)
    public var enableImmediateFeedbackForAnswers: Bool
    
    @UserDefault(UserDefaultConfigKey.coursesPurchased, false)
    public var iscoursePurchased: Bool
    
    @UserDefault(UserDefaultConfigKey.videosPurchased, false)
    public var isVideosPurchased: Bool
    
    @UserDefault(UserDefaultConfigKey.videoLoaded, false)
    public var isVideosLoaded: Bool
    
    @UserDefault(UserDefaultConfigKey.lastPlayedVideosIdentifiers, [])
    public var lastPlayedVideosIdentifiers: [String]
    
    @UserDefault(UserDefaultConfigKey.resultTotalQuestions, 0)
    public var resultTotalQuestions: Int
    
    @UserDefault(UserDefaultConfigKey.resultCorrectQuestions, 0)
    public var resultCorrectQuestions: Int
    
    @UserDefault(UserDefaultConfigKey.resultIncorrectQuestions, 0)
    public var resultIncorrectQuestions: Int
    
    @UserDefault(UserDefaultConfigKey.resultPercentage, 0.0)
    public var resultPercentage: Double
    
    @UserDefault(UserDefaultConfigKey.returningUser, false)
    public var returningUser: Bool
    
    
    public func resetExamSettings() {
       // self.examSettings = ExamSettings()
    }
    
    public var appLaunchedEarlier: Bool {
        let defaults = UserDefaults.standard
        if defaults.string(forKey: UserDefaultConfigKey.appLaunchedEarlier) != nil {
            return true
        } else {
            defaults.set(true, forKey: UserDefaultConfigKey.appLaunchedEarlier)
            UserDefaults.standard.synchronize()
            return false
        }
    }
    
}

@propertyWrapper
public struct UserDefault<T> {
    
    let key: String
    let defaultValue: T
    
    init(_ key: String, _ defaultValue: T) {
        self.key = key
        self.defaultValue = defaultValue
    }
    
    public var wrappedValue: T {
        get {
            return UserDefaults.standard.object(forKey: key) as? T ?? defaultValue
        } set {
            UserDefaults.standard.set(newValue, forKey: key)
            UserDefaults.standard.synchronize()
        }
    }
}

extension UserDefault where T: ExpressibleByNilLiteral {
    init(_ key: String) {
        self.init(key, nil)
    }
}
