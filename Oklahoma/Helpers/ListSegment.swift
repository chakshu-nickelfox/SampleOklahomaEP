//
//  ListSegment.swift
//  Oklahoma
//
//  Created by Chakshu Dawara on 27/12/23.
//

import UIKit
import Foundation
import XCGLogger

enum ImpactIntensity {
    case defaultIntensity
    case heavy
    case light
    case medium
    case rigid
    case soft
}

extension IdentifyOptionsState {
    
    var image: String {
        switch self {
        case .correct:
            return Images.All.correctAnswer.rawValue
        case .incorrect:
            return Images.All.incorrectAnswer.rawValue
        case .none:
            return ""
        }
    }
    
    var backgroundColor: UIColor {
        switch self {
        case .correct:
            return Colors.greenColor
        case .incorrect:
            return Colors.redColor
        case .none:
            return Colors.primaryGray
        }
    }
}

enum ListSegment: Int {
    case all
    case downloads
    case bookmarks
    
    
    var title: String {
        switch self {
        case .all:
            return Text.allAudiobooks.localize()
        case .downloads:
            return Text.downloads.localize()
        case .bookmarks:
            return Text.bookmarks.localize()
        }
    }
    
    var index: Int {
        switch self {
        case .all:
            return 0
        case .downloads:
            return 1
        case .bookmarks:
            return 2
        }
    }
}

enum MediaAction: String {
    case bookmark
    case addToDeck
    
    var unselectedImage: String {
        switch self {
        case .bookmark:
            return "bookmark_audio"
        case .addToDeck:
            return "uncheck"
        }
    }
    
    var selectedImage: String {
        switch self {
        case .bookmark:
            return "bookmarked_audio"
        case .addToDeck:
            return "newchecked"
        }
    }
}

enum MenuOptions: Int {
    case videos
    case identify
    case settings
    
    var tabBarIndex: Int {
        switch self {
        case .videos:
            return TabBarItems.videos.rawValue
        case .identify:
            return TabBarItems.identify.rawValue
        case .settings:
            return TabBarItems.settings.rawValue
        }
    }
}

enum TabBarItems: Int {
    case courses
    case audiobook
    case home
    case examPrep
    case videos
    case identify
    case flashcard
    case settings
}

enum UpdateType {
    case required
    case unavailable
}
