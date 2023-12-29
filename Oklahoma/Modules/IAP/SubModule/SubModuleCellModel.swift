//
//  SubModuleCellModel.swift
//  Oklahoma
//
//  Created by Chakshu Dawara on 26/12/23.
//

import Foundation
import UIKit

enum SubModule {
    case audiobook, examPrep

//    var tabIndex: Int {
//        switch self {
//        case .examPrep: return TabBarItem.examPrep.rawValue
//        case .audiobook: return TabBarItem.audiobook.rawValue
//        }
//    }

    var title: String {
        switch self {
        case .examPrep:
            return "ExamPrep"
        case .audiobook:
            return "AudioBook"
        }
    }
    
    var iconName: String {
        switch self {
        case .examPrep:
            return "exam_prep"
        case .audiobook:
            return "audiobookIcon"
        }
    }

    var description: String {
        switch self {
        case .audiobook:
            return """
  \u{2022}  Downloadable and accessible offline.
  \u{2022}  Keep track of notes and sections to review via bookmarks.
  \u{2022}  Listen at your own pace by speeding up or slowing down the reading.
"""
        case .examPrep:
            return """
Use the 502 Exam Prep questions to confirm your understanding of the content in the Chief Officer, 4th Edition manual.
"""
        }
    }
}
struct SubModuleCellModel {
    private let module: SubModule
    
    init(_ module: SubModule) {
        self.module = module
    }
    
    var title: String {
        return self.module.title
    }
    
    var description: String {
        return self.module.description
    }

    var icon: UIImage? {
        return UIImage(named: self.module.iconName)
    }
    
//    var index: Int {
//        return self.module.tabIndex
//    }
}

//struct AppVersionModel {
//    let title: String = AppUtility.appVersionDisplayName
//}
