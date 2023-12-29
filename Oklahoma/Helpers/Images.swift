//
//  Images.swift
//  Oklahoma
//
//  Created by Chakshu Dawara on 27/12/23.
//

import UIKit

struct Images {
    
    enum Splash: String {
        case launchImage = "LaunchImage"
        
        var image: UIImage? {
            return UIImage(named: self.rawValue)
        }
    }
    
    enum All: String {
        case appLogoIPad = "app_logo_iPad"
        case appLogoIPhone = "app_logo_iPhone"
        case buyAll = "buy_All"
        case backgroundPhoneImage = "bg_examprep"
        case backgroundPadLanscapeImage = "bg_pad_landscape"
        case backward30 = "backward_30_audio"
        case backward = "backward_audio"
        case bookmark = "bookmark_audio"
        case bookmarked = "bookmarked_audio"
        case correctAnswer = "correct_answer"
        case correctAnswerIcon = "CorrectAnswerIcon"
        case checkedWhiteBoxIcon = "checkedWhiteBoxIcon"
        case checkedIcon = "CheckedBoxIcon"
        case courseInProgress = "courseInProgress"
        case courseCompleted = "courseCompleted"
        case courseIcon = "coursedefault"
        case coverImage = "audioLogo"
        case downloadAllWhite = "downloadAllWhite"
        case dropDown = "dropDown"
        case delete = "delete_audio"
        case deleteVideo = "deleteVideo"
        case downloadAll = "downloadAll"
        case deleteAllRed = "deleteAllRed"
        case downloadedGreen = "downloadedGreen"
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
        case goBack = "back_icon"
        case incorrectAnswerIcon = "IncorrectAnswerIcon"
        case incorrectAnswer = "incorrect_answer"
        case menu = "menu_audio"
        case none = "none"
        case pause = "pause-audio"
        case play = "play_audio"
        case playDownloadedAudio = "downloaded-audio"
        case redCross = "red_cross"
        case replay = "replay"
        case sliderThumbImage = "sliderThumbImage"
        case uncheckedIcon = "UncheckedBoxIcon"
        case coursesSelectedTab = "courses_updated_yellow"
        case examPrepSelectedTab = "exam_prep_updated_yellow"
        case videosSelectedTab = "video_updated_yellow"
        case coursesUnselectedTab = "courses_updated"
        case examPrepUnselectedTab = "exam_prep_updated"
        case videosUnselectedTab = "video_updated"
      
        var image: UIImage? {
            return UIImage(named: self.rawValue)
        }
    }
}
