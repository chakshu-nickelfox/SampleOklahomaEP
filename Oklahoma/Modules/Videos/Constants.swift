//
//  Constants.swift
//  BaseOklahoma
//
//  Created by Ravindra Soni on 11/12/18.
//  Copyright © 2018 Nickelfox. All rights reserved.
//

import Foundation
import UIKit

struct Constants {
    
    struct ProductIdentifier {
        static let audiobookProductIdentifier = "org.ifsta.e7.audiobook"
        static let examPrepProductIdentifier = "75179"
        static let courseProductIdentifier = "75181"
        static let videosProductIdentifier = "75180"
        static let flashcardsProductIdentifier = "flashcardsProductIdentifier"
        static let appStoreAppId = "1441449622"
    }
    
    static let courses = "Courses"
    static let audioBook = "Audiobook"
    static let home = "Home"
    static let examPrep = "Exam Prep"
    static let more = "More"
    static let videos = "Videos"
    static let identify = "Identify"
    static let settings = "Settings"
    
    static let aboutus = "About"
    static let allSelected = "All Selected"
    static let bookmarkRemoved = "bookmark removed"
    static let bookmarked = "bookmarked"
    static let buyall = "Buy All"
    static let cancel = "Cancel"
    static let cancelDownload = "Cancel Download"
    static let cancelDownloads = "Cancel Downloads"
    static let cancelTitle = "Cancel"
    static let connectInternetMessage = "Please connect to internet to listen audiobooks."
    static let download = "Download all"
    static let deleteChapterTitle = "Delete chapter"
    static let deleteChapter = "Are you sure you want to delete this chapter? You can download it again."
    static let deleteAll = "Delete all"
    static let deleteSelected = "Delete selected"
    static let downloadSelected = "Download Selected"
    static let downloadSuccessful = "download successful"
    static let downloadIsInProgress = "Download is already in progress"
    static let emptyBookmark = "Empty bookmark title"
    static let filesDeleted = "File(s) deleted successfully"
    static let appTitle = "Essentials of Fire Fighting"
    static let fullysearchable = "Fully searchable text"
    static let goBack = "Are you sure you want to go back?"
    static let identifyButton = "Identify"
    static let noTitle = "No"
    static let noInternet = "No Internet Connection"
    static let noreports = "No reports available."
    static let noBookmarks = "No bookmarks yet"
    static let noAudiobookFound = "No audiobook found"
    static let noAudiobookYet = "No audiobook yet"
    static let noDownloads = "No downloads yet"
    static let noAudioBookDownloaded = "Currently no audiobook is available offline to delete!"
    static let offlineDownload = "Download offline"
    static let okTitle = "Ok"
    static let purchaseAt = "Find more eBooks at :"
    static let practiceExam = "Practice Exam"
    static let repeatedTimeNote = "A note with the same time already exist"
    static let repeatedMessageNote = "A note with the same title already exist"
    static let selected = "Selected"
    static let successfullyDeleted = "successfully deleted"
    static let tool = "Identify"
    static let videoButton = "Videos"
    static let versionNumber: Float = 1.0
    static let versionNumberKey = "versionNumberKey"
    static let yesTitle = "Yes"
    static let updateRequired = "Update Required\n"
    static let update = "Update"
    static let setLang = "SETLANG"
    static let dismiss = "Dismiss"
    static let english = "English"
    static let FloatAlertView = "FloatAlertView"
    static let alert = "alert"
    static let flashCard = "Flashcard"
    
    struct Video {
        static let isVideoContentUnlocked = "isVideoContentUnlocked"
        static let vimeoClientIdentifier = "60c019255a4587516b1d35efe10e657e566cdddc"
        static let vimeoClientSecret = "Y956ThuL+kdLs7AQHVO84tuCgVIjsHsUfj/8shULJF1o0KcikbEe+z+qQUbwu5ZGK0Fn4e9QByYCVjk7XuHCbT+aq6USKtOJ3WF+2/Lsi2htGMREmU8RUalOPy5+oEE/"
        static let vimeoAccessToken = "62a0caf35afd8ab970c4ecf93b7df844"
        static let fileExtension = ".mp4"
        static let searchPlaceHolder = "Search for a video"
        static let allVideos = "All Videos"
        static let noVideo = "No video yet"
        static let noVideoFound = "No video found"
        static let skillVideos = "Skill Videos"
        static let videos = "Videos"
    }
    
    struct Identify {
        static let initializedIdentifyQuestions = "initializedIdentifyQuestions"
        static let begin  = "Let's Begin"
        static let reset = "Reset Progress"
        static let completedModuleMessage =  "Congratulation You have completed container identification"
        static let areYouSureYouWantToExit = "Are you sure you want to exit"
    }
    
    struct ExamPrep {
        static let examprep = "Exam Prep"
        static let areYouSureYouWantToExit = "Are you sure you want to exit"
        static let clearStudyDesk = "Remove all questions from study deck?"
        static let clearReports = "Clear all test results?"
        static let endQuiz = "Exit"
        static let exitWithoutScore = "Exit without Score"
        static let isExamPrepContentUnlocked = "isExamPrepContentUnlocked"
        static let initializedExamPrepChapters = "initializedExamPrepChapters"
        static let initializedExamPrepQuestions = "initializedExamPrepQuestions"
        static var multipleChoiceAttempts = "multipleChoiceAttempts"
        static let noreports = "No reports available."
        static let reportsCleared = "Reports cleared for all chapters."
        static let reset = "Reset"
        static let scoreAndExit = "Score and Exit"
        static let studyDeskEmpty = "No questions are in the study deck."
        static let studyDesk = "Study Deck"
        static let studyDeckCleared = "Removed all chapters from study deck."
    }
    
    struct Course {
//        static let isCoursesContentUnlocked = "isCoursesContentUnlocked"
        static let isCourseContentUnlocked = "isCourseContentUnlocked"
        static let courses = "Interactive Course"
    }
    
    struct AudioBook {
//        static let isAudiobookContentUnlocked = "isAudiobookContentUnlocked"
        static let isAudioBookContentUnlocked = "isAudiobookContentUnlocked"
        static let searchPlaceHolder = "Search for an audiobook"
        static let addBookmark = "+ Bookmark"
        static let removeBookmark = "- Bookmark"
        static let checkResults = "Check Results"
        static let audiobooks = "Audiobooks"
        static let audiobook = "Audiobook"
        static let noAudioFound = "No audiobook found"
        static let noAudio = "No audiobook yet"
    }
    
    struct IAP {
        static let productIdentifierIsNotAvailable = "Product identifier is not available, it will be a dummy purchase for testing."
        static let error = "Error"
        static let purchase = "Purchase"
        static let purchaseComplete = "Purchase Complete"
        static let thereNoPurchasedRestore = "There are no purchased items to restore."
        static let previousPurchasesRestored = "Previous In-App Purchases have been restored!"
        static let buyinItemNotPossible = "Buying this item is not possible at the moment."
    }
    
    struct FlashCard {
        static let offlineFlashCard = "offline_flashcards"
        static let json = "json"
        static let flashcardIndex = 6
    }
}

struct Font {
    static let RobotoBlack = UIFont(name: "Roboto-Black", size: 16.0)!
    static let RobotoBlackItalic = UIFont(name: "Roboto-BlackItalic", size: 16.0)!
    static let RobotoBold = UIFont(name: "Roboto-Bold", size: 14.0)!
    static let RobotoBoldItalic = UIFont(name: "Roboto-BoldItalic", size: 16.0)!
    static let RobotoItalic = UIFont(name: "Roboto-Italic", size: 16.0)!
    static let RobotoLight = UIFont(name: "Roboto-Light", size: 16.0)!
    static let RobotoLightItalic = UIFont(name: "Roboto-LightItalic", size: 16.0)!
    static let RobotoMedium = UIFont(name: "Roboto-Medium", size: 16.0)!
    static let RobotoMediumItalic = UIFont(name: "Roboto-MediumItalic", size: 16.0)!
    static let RobotoRegular = UIFont(name: "Roboto-Regular", size: 14.0)!
    static let RobotoThin = UIFont(name: "Roboto-Thin", size: 16.0)!
    static let RobotoThinItalic = UIFont(name: "Roboto-ThinItalic", size: 16.0)!
}
