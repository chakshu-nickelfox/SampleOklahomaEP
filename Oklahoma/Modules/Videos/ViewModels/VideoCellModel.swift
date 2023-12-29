//
//  VideoCellModel.swift
//  Oklahoma
//
//  Created by Chakshu Dawara on 27/12/23.
//

import Foundation
import UIKit
import ReactiveSwift

class VideoCellModel {
    
    var video: Video
    var percentage:Double = 0.0
    var isSelected: Bool = false
    var isHidden: Bool = true
    var hideDownloadButton: Bool = false
    var aplha: Double = 1
    var userInterationEnabled: Bool = true
    var chapterDownloading = MutableProperty(false)
    var row = 0
    var indexPath: IndexPath?
    
    init(video: Video) {
        self.video = video
    }
    
    var chapterIdentifier: String {
        return "\(Text.skill.localize()) " + self.video.identifer
    }
    
    var chapterNumber: String {
        return self.video.chapterNumber
    }
    var chapterTitle: String {
        return self.video.chapterTitle
    }
    var totalChapters: String {
        return String(self.video.subVideos.count)
    }
    var totalVideosDuration: String {
        return self.video.videoDuration
    }
    
    var numberOfSubVideos: String {
        return self.video.subVideos.count > 1 ? String (self.video.subVideos.count) + " \(Text.videos.localize())":  "1" + " \(Text.video.localize())"
    }
    var videoId: String {
        return self.video.videoId
    }
    var videoidentifer: String {
        return self.video.identifer
    }
    
    var downloadPath: String {
        return self.video.downloadPath
    }
    
    var isBookmarked: Bool {
        return self.video.isBookmarked
    }
    
    var thumbnailImage: String {
        return self.video.thumbnail
    }
    
    var downloadState: DownloadState {
        let index = video.isDownloaded ? 2 : (video.isDownloading ? 1 : 0)
        return DownloadState(rawValue: index) ?? .none
    }
    
    var steps: NSMutableAttributedString {
        
        let skillSheetSteps = self.video.stepsList
        let attrs = [(NSAttributedString.Key.font): Font.RobotoRegular]
        let previousAttributedText = NSMutableAttributedString(string:"", attributes: (attrs))
        
        for i in 0..<skillSheetSteps.count {
            var currentStep = skillSheetSteps[i] + "\n"
            currentStep =  currentStep.replacingOccurrences(of: "\"", with: "")
            let currentStepComponents = currentStep.components(separatedBy: ":")
            
            if(currentStepComponents.count > 1) {
                // Mark the Step title bold
                let stepCountStr = currentStepComponents[0]
                var attrs = [(NSAttributedString.Key.font): Font.RobotoBold]
                let attributedStepString = NSMutableAttributedString(string:stepCountStr + ": ", attributes:(attrs))
                
                // Make the other text regular
                let stepDetail = currentStepComponents[1]+"\n"
                attrs = [(NSAttributedString.Key.font): Font.RobotoRegular]
                let stepDetailString = NSMutableAttributedString(string:stepDetail, attributes: (attrs))
                
                attributedStepString.append(stepDetailString)
                previousAttributedText.append(attributedStepString)
            }
            // Make the other text regular
            else {
                let attrs = [(NSAttributedString.Key.font): Font.RobotoRegular]
                let currentStepString = NSMutableAttributedString(string: currentStep + " ", attributes: (attrs))
                previousAttributedText.append(currentStepString)
                
            }
        }
        return previousAttributedText
    }
    
    public var currentPercentage: Double {
        get {
            return self.percentage
        }
        set {
            self.percentage = newValue
        }
    }
}

extension VideoCellModel {
    
    func updateBookmark() {
        self.video.updateBookmark()
    }
    
    func updateDownload(value: Int) {
        self.video.updateDownload(value: value)
    }
    
}


class VideoDesriptionCellModel {
    
    var video: Video
    var percentage:Double = 0.0
    var buttonTitle: String = ""
    
    init(video: Video) {
        self.video = video
    }
    
    var downloadPath: String {
        return self.video.downloadPath
    }
    
    var chapterNumber: String {
        return self.video.chapterNumber
    }
    
    var downloadState: DownloadState {
        let index = video.isDownloaded ? 2 : (video.isDownloading ? 1 : 0)
        return DownloadState(rawValue: index) ?? .none
    }
    
    var chapterIdentifier: String {
        return self.video.chapterIdentifier
    }
    
    
    public var currentPercentage: Double {
        set {
            self.percentage = newValue
        }
        get {
            return self.percentage
        }
    }
    
    var chapterTitle: String {
        return self.video.chapterTitle
    }
    
    var isBookmarked: Bool {
        return self.video.isBookmarked
    }
    
    
    var steps: NSMutableAttributedString {
        
        let skillSheetSteps = self.video.stepsList
        let attrs = [(NSAttributedString.Key.font): Font.RobotoRegular]
        let previousAttributedText = NSMutableAttributedString(string:"", attributes:(attrs))
        
        for i in 0..<skillSheetSteps.count {
            var currentStep = skillSheetSteps[i] + "\n"
            currentStep =  currentStep.replacingOccurrences(of: "\"", with: "")
            let currentStepComponents = currentStep.components(separatedBy: ":")
            
            if(currentStepComponents.count > 1) {
                //Mark the Step title bold
                let stepCountStr = currentStepComponents[0]
                //print(stepCountStr)
                var attrs = [(NSAttributedString.Key.font): Font.RobotoBold]
                let attributedStepString = NSMutableAttributedString(string:stepCountStr + ": ", attributes:(attrs))
                
                //Make the other text regular
                let stepDetail = currentStepComponents[1]+"\n"
                attrs = [(NSAttributedString.Key.font): Font.RobotoRegular]
                let stepDetailString = NSMutableAttributedString(string:stepDetail, attributes:(attrs))
                
                attributedStepString.append(stepDetailString)
                previousAttributedText.append(attributedStepString)
            }
            //Make the other text regular
            else {
                let attrs = [(NSAttributedString.Key.font): Font.RobotoRegular]
                let currentStepString = NSMutableAttributedString(string: currentStep + " ", attributes:(attrs))
                previousAttributedText.append(currentStepString)
                
            }
        }
        return previousAttributedText
        
    }
    
    var lastProgressTime: Double {
        return self.video.lastProgressTime
    }
}

extension VideoDesriptionCellModel {
    
    func updateDownload(value: Int) {
        self.video.updateDownload(value: value)
    }
}


struct SimilarSkillsCellModel {
    var name:String
}

struct SearchCellModel {
    var name:String
}


class VideoPlayedCellModel {
    
    var videos: [LastPlayedCellModel]
    
    init(_ videos: [LastPlayedCellModel]) {
        self.videos = videos
    }
}

class LastPlayedCellModel {
    
    var video: Video
    
    init(_ video: Video) {
        self.video = video
    }
    
    var title: String {
        return self.video.chapterIdentifier
    }
    
    var subtitle: String {
        return self.video.chapterTitle
    }
    
    var bookmarked: Bool {
        return self.video.isBookmarked
    }
    
     var lastProgressTime: Double {
        return self.video.lastProgressTime
    }
    
    func updateBookmark() {
        self.video.updateBookmark()
    }
    
    var videoidentifer: String {
        return self.video.identifer
    }
    
    var thumbnailImage: String {
        return self.video.thumbnail
    }
}
