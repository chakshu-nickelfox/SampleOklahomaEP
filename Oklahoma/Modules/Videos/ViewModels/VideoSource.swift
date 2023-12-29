//
//  VideoSource.swift
//  Oklahoma
//
//  Created by Chakshu Dawara on 27/12/23.
//

import Foundation

protocol VideoSourceDelegate: AnyObject {
    func didFinishDownload(forModel model: VideoCellModel, result: Bool)
    func didUpdate(progress: FileProgress, for model: VideoCellModel)
}

class VideoSource: NSObject {
    
    static let shared = VideoSource()
    var allVideoModels: [VideoCellModel]
    var allChapters: [Video]
    var delegate: VideoSourceDelegate?
    var playerDelegate: VideoSourceDelegate?
    
    private override init() {
//        let allVideos =  VideoManager.getAllChapters()
///        Function initial Videos chapters is called only for 7th migration schema version, above that getAllChapters is called at this place
        let allVideos =  VideoManager.getAllInitialVideoChapters()
        allChapters = allVideos
        allVideoModels = allVideos.map({ VideoCellModel(video: $0) })
    }
    
    func refreshAllVideos() {
        let allVideos =  VideoManager.getAllChapters()
        allChapters = allVideos
        allVideoModels = allVideos.map({ VideoCellModel(video: $0) })
    }
    
    func downloadVideo(model: VideoCellModel, pathComponent: String,
                                   videoUrl: URL) {
        model.video.downloadVideo(pathComponent: pathComponent, videoUrl: videoUrl, downloadProgressed: { progress in
            
            let downloadPercentage = progress.fractionCompleted
            if model.currentPercentage == 0.0 || progress.fractionCompleted == 1.0 {
                model.currentPercentage = downloadPercentage
                model.percentage = downloadPercentage
                self.delegate?.didUpdate(progress: progress, for: model)
                self.playerDelegate?.didUpdate(progress: progress, for: model)
            } else {
                let previous = model.currentPercentage.rounded(toPlaces: 1)
                let current = progress.fractionCompleted.rounded(toPlaces: 1)
                // Only update when just after 10% complete
                if current > previous {
                    model.currentPercentage = downloadPercentage
                    model.percentage = downloadPercentage
                    self.delegate?.didUpdate(progress: progress, for: model)
                    self.playerDelegate?.didUpdate(progress: progress, for: model)
                }
            }
        })
        {
            result in
            if result {
                self.delegate?.didFinishDownload(forModel: model, result: result)
                self.playerDelegate?.didFinishDownload(forModel: model, result: result)
            }
        }
    }
    
    func cancelAllDownloads() {
        self.allVideoModels.forEach {
            $0.isSelected = false
            $0.isHidden = true
            $0.hideDownloadButton = false
            $0.aplha = 1.0
            $0.userInterationEnabled = true
            let chapterNumber = $0.chapterNumber
            let pathComponent = chapterNumber + Constants.Video.fileExtension
            $0.video.cancelDownloadVideo(pathComponent: pathComponent)
            if $0.downloadState != .downloadComplete{
                $0.video.updateDownload(value: DownloadState.notDownloaded.rawValue)
                $0.video.updateDownloadPath(value: "")
            }
            $0.chapterDownloading.value = false
            $0.percentage = 0.0
            $0.currentPercentage = 0.0
        }
    }
    
    func resetProgress(for model: VideoCellModel) {
        for myModel in self.allVideoModels where model.chapterIdentifier == myModel.chapterIdentifier {
            myModel.currentPercentage = 0.0
            myModel.percentage = 0.0
        }
    }
}
