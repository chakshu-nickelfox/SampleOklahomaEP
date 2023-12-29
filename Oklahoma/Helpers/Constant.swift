//
//  Constant.swift
//  Oklahoma
//
//  Created by Chakshu Dawara on 25/12/23.
//

import Foundation
import UIKit

struct Constant {
    
    struct ProductIdentifier {
        static let audiobookProductIdentifier = "org.ifsta.flse4.audiobook"
        static let examPrepProductIdentifier = "org.ifsta.flse4.examprep"
        static let appStoreAppId = "6467187610"
    }
    
    static let ok = "Ok"
    static let yes = "Yes"
    static let no = "No"
    static let reset = "Reset"
    static let cancel = "Cancel"
    static let oops = "Oops!"
    static let successfullyDeleted = "successfully deleted"
    static let selected = "Selected"
    static let allSelected = "All Selected"
    static let floatAlertView = "FloatAlertView"
    static let alert = "alert"
    static let langEnglishCode = "en"
    static let noInternet = "No Internet Connection"
    
    static let welcome = "Welcome"
    static let welcomeCellModelText = "We have been waiting for you, lets begin!"
    
    static let homeAboutUsCellModelText =
    "The Fire and Life Safety Educator, 4th Edition, Manual provides fire and emergency service " +
    "personnel, and civilians with the basic information necessary to meet the job performance " +
    "requirements (JPRs) of NFPA 1030, Standard for Professional Qualifications for Fire Prevention " +
    "Program Positions, 2024 Edition, for Fire and Life Safety Educator Levels I and II and the " +
    "level of Fire and Life Safety Program Manager as shown in Chapters 9, 10, and 11 of the " +
    "standard. This App focuses on life safety educators assigned to the implementation, management, " +
    "and administration of fire and life safety programs, and supports the content provided in our " +
    "Fire and Life Safety Educator, 4th Edition, Manual. Included FREE in this App are Flashcards " +
    "and Chapter 1 of the Exam Prep and Audiobook."
    
    static let homeAudioBooksCellModelText =
    "Purchase the Fire and Life Safety Educator, 4th Edition, Audiobook through the App. All 13 " +
    "chapters are narrated in their entirety for 9 hours of content. Features include offline " +
    "access, bookmarks, and the ability to listen at your own speed. All users have free " +
    "access to Chapter 1."
    
    static let homeExamPrepCellModelText =
    "Use the 325 IFSTA®-validated Exam Prep questions to confirm your understanding of the content " +
    "in the Fire and Life Safety Educator, 4th Edition, Manual. The Exam Prep covers all 13 " +
    "chapters of the Manual. Exam Prep tracks and records your progress, allowing you to review " +
    "your exams and study your weaknesses. In addition, your missed questions are automatically " +
    "added to your study deck. This feature requires an in-app purchase. All users have free " +
    "access to Chapter 1."
    
    static let flashCardCellModelText =
    "Review all 120 key terms and definitions found in all " +
    "13 chapters of the Fire and Life Safety Educator, 4th Edition, Manual with flashcards. Study " +
    "selected chapters or combine the deck together This feature is FREE for all users."
    
    struct ExamPrep {
        static let examPrep = "Exam Prep"
        static let versionNumberKey = "versionNumberKey"
        static let versionNumber: Float = 1.0
        static let initializedExamPrepChapters = "initializedExamPrepChapters"
        static let isExamPrepContentUnlocked = "isExamPrepContentUnlocked"
        static let studyDeskEmpty = "No questions are in the study deck."
        static let clearReports = "Clear all test results?"
        static let noReports = "No reports available."
        static let reportsCleared = "Reports cleared for all chapters."
        static let endQuiz = "Exit"
        static let scoreAndExit = "Score and Exit"
        static let exitWithoutScore = "Exit without Score"
        static let areYouSureYouWantToExit = "Are you sure you want to exit"
        static let reset = "Reset"
        static let studyDeckEmpty = "No questions are in the study deck."
        static let clearStudyDesk = "Remove all questions from study deck?"
        static let studyDeckCleared = "Removed all chapters from study deck."
        static let viewReports = "View Reports"
    }
    
    struct AudioBook {
        static let audiobook = "Audiobook"
        static let repeatedTimeNote = "A note with the same time already exist"
        static let repeatedMessageNote = "A note with the same title already exist"
        static let isDeleted = " is deleted."
        static let downloadSelected = "Download Selected"
        static let filesDeleted = "File(s) deleted successfully"
        static let deleteSelected = "Delete selected"
        static let noBookmarks = "No bookmarks yet"
        static let noAudiobookFound = "No audiobook found"
        static let noAudiobook = "No audiobook yet"
        static let noAudioBookDownloaded = "Currently no audiobook is available offline to delete!"
        static let deleteChapterTitle = "Delete chapter"
        static let deleteChapter = "Are you sure you want to delete this chapter? You can download it again."
        static let connectInternetMessage = "Please connect to internet to listen audiobooks."
        static let emptyBookmark = "Empty bookmark title"
        static let noDownloads = "No downloads yet"
        static let buyall = "Buy All"
        static let delete = "Delete"
        static let deleteAll = "Delete all"
        static let downloads = "Downloads"
        static let download = "Download all"
        static let cancelDownloads = "Cancel Downloads"
        static let cancelDownload = "Cancel Download"
        static let downloadSuccessful = "download successful"
        static let chapter = "Chapter "
        static let isAudioBookContentUnlocked = "isAudiobookContentUnlocked"
        static let searchPlaceHolder = "Search for an audiobook"
        static let bookmarkRemoved = "bookmark removed"
        static let bookmarked = "Bookmarked"
        static let addBookmark = "+ Bookmark"
        static let removeBookmark = "- Bookmark"
        static let checkResults = "Check Results"
        static let audiobooks = "Audiobooks"
        static let unableToDelete = "Unable to delete at the moment"
        static let floatingButtonBottomConstant = 110.0
    }
    
    struct UpdateApp {
        static let updateRequired = "Update Required\n"
    }
    
    struct IAP {
        static let error = "Error"
        static let purchase = "Purchase"
        static let purchaseComplete = "Purchase Complete"
        static let noPurchasedRestore = "There are no purchased items to restore."
        static let previousPurchasesRestored = "Previous In-App Purchases have been restored!"
        static let dummyPurchase = "Product identifier is not available, it will be a dummy purchase for testing."
        static let buyingItemNotPossible = "Buying this item is not possible at the moment."
        static let noProductIdentifiersFound = "No In-App Purchase product identifiers were found."
        static let noIAPFound = "No In-App Purchases were found."
        static let unableToFetchProduct = "Unable to fetch available In-App Purchase products at the moment."
        static let iapProcessCancelled = "In-App Purchase process was cancelled."
        static let unknownError = "Unknown Error"
    }
    
    struct Home {
        static let home = "Home"
        static let about = "About"
        static let learnMore = "Learn More"
    }
    
    struct Flashcard {
        static let flashcard = "Flashcard"
        static let offlineFlashCard = "offline_flashcards"
        static let json = "json"
    }
}
