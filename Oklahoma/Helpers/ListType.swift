//
//  ListType.swift
//  Oklahoma
//
//  Created by Chakshu Dawara on 25/12/23.
//

import Foundation
import UIKit

enum ListType {
    case examPrep
    case reports
    case studyDeckList
}

enum Settings {
    case examPrep
    case audio
    
    static func getSettings(forModule: Settings) -> [String] {
        
        switch forModule {
        case .examPrep:
            return  ["Clear test results", "Clear Study deck"]
        case .audio:
            return  ["Download All", "Delete All"]
        }
    }
}

enum Option {
    case delete
    case download
}

enum Queue {
    
    case add
    case remove
}

enum AudioPlayerAction {
    case next
    case previous
}

enum ShowButton {
    case download
    case delete
    case cancel
    case buy
    case cancelDownload
    
    var titleColor: UIColor {
        return (self == .cancel || self == .delete || self == .cancelDownload) ? Colors.redColor : Colors.primaryColor
    }
    
    var buttonImage: UIImage? {
        return self == .cancelDownload ? Image.AudioBooks.redCross.image : nil
    }
}

enum NavigationType {
    case practiceExam
    case studyDeck
    
    var typeTitle: String {
        return self == .practiceExam ? "Practice Exam" : "Study Deck"
    }
}

enum IdentifyNextQuestionCellButtonType {
    case next
    case skip
}

enum IdentifyStartButton {
    case begin
    case reset
    
    var title: String {
        switch self {
        case .begin:
            return "Let's Begin"
        case .reset:
            return "Reset Progress"
        }
    }
}


enum IdentifyModuleProgress {
    case completed
    case notCompleted
    case progress
}

enum VideoType {
    case parent
    case subVideo
}


enum VideoPlayMode: String {
    case offline = "Offline"
    case online = "Online"
}

enum QuestionType: String {
    case attempted = "ATTEMPTED"
    case unattempted = "UNATTEMPTED"
}

public struct Image {
    
    enum Splash: String {
        case launchImage = "LaunchImage"
        
        var image: UIImage? {
            return UIImage(named: self.rawValue)
        }
    }
    
    enum AudioBooks: String {
        case none = "none"
        case backward30 = "backward_30_audio"
        case backward = "backward_audio"
        case bookmark = "bookmark_audio"
        case bookmarked = "bookmarked_audio"
        case darkBookmark = "dark_bookmark_audio"
        case darkBookmarked = "dark_bookmarked_audio"
        case darkPause = "dark_pause_audio"
        case darkPlay = "dark_play_audio"
        case darkLargePause = "dark_largePause_audio"
        case darkLargePlay = "dark_largePlay_audio"
        case disabledBackward = "disabled_backward_audio"
        case disabledForward = "disabled_forward_audio"
        case downArrow = "down_arrow_audio"
        case downloadAudio = "download_audio"
        case forward30 = "forward_30_audio"
        case forward = "forward_audio"
        case menu = "menu_audio"
        case pause = "pause_audio"
        case play = "play_audio"
        case playDownloadedAudio = "downloaded-audio"
        case pauseDownloadedAudio = "downloaded_audiopaused"
        case coverImage = "audioLogo"
        case delete = "delete_audio"
        case sliderThumbImage = "sliderThumbImage"
        case downloadAll = "downloadAll"
        case buyAll = "buy_All"
        case downloadAllWhite = "downloadAllWhite"
        case deleteAllRed = "deleteAllRed"
        case downloadedGreen = "downloadedGreen"
        case redCross = "red_cross"
        
        var image: UIImage? {
            return UIImage(named: self.rawValue)
        }
    }
    
    enum ExamPrep: String {
        case checkedIcon = "CheckedBoxIcon"
        case uncheckedIcon = "UncheckedBoxIcon"
        case incorrectAnswerIcon = "IncorrectAnswerIcon"
        case correctAnswerIcon = "CorrectAnswerIcon"
        case checkedWhiteBoxIcon = "checkedWhiteBoxIcon"
        case correctAnswer = "correct_answer"
        case incorrectAnswer = "incorrect_answer"
        case backgroundPhoneImage = "bg_phone"
        case backgroundPadPortraitImage = "bg_pad_portrait"
        case backgroundPadLanscapeImage = "bg_pad_landscape"
        case examPrepSelectedTab = "exam_prep_updated_yellow"
        case examPrepUnselectedTab = "exam_prep_updated"
        
        var image: UIImage? {
            return UIImage(named: self.rawValue)
        }
        
    }
    
    enum Videos: String {
        case goBack = "back_icon"
        case downloadVideo = "downloadAllWhite"
        case dropDown = "dropDown"
        case delete = "delete_audio"
        case deleteVideo = "deleteVideo"
        case downloadAll = "downloadAll"
        
        var image: UIImage? {
            return UIImage(named: self.rawValue)
        }
    }
    
    enum Flashcards: String {
        case flashcardSelectedTab = "flashcard_selected"
        case flashcardUnSelectedTab = "flashcard_unselected"
        
        var image: UIImage? {
            return UIImage(named: self.rawValue)
        }
    }
    
    enum IAP: String {
        case appLogoIPhone = "app_logo_iPhone"
        
        var image: UIImage? {
            return UIImage(named: self.rawValue)
        }
    }
    
}
