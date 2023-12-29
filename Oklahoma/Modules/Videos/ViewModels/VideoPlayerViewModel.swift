//
//  VideoPlayerViewModel.swift
//  Oklahoma
//
//  Created by Chakshu Dawara on 27/12/23.
//

import Foundation
import ReactiveSwift
import RealmSwift
import VimeoNetworking
import UIKit
import FLUtilities
import AnyErrorKit
import VersaPlayer

protocol VideoPlayerViewModelDelegate: BaseViewModelProtocol {
    func loadVideo()
    func reload()
    func reloadRow(indexPath: IndexPath)
    func didStartFetching()
    func didEndFetching()
    func showAlert(_ message: String, type: AlertType)
}

class VideoPlayerViewModel {
    
    private var sectionModels = MutableProperty<[SectionModel]>([])
    weak var view: VideoPlayerViewModelDelegate!
    var videoModel = MutableProperty<VideoCellModel?>(nil)
    var vimeoClient: VimeoClient! = nil
    var authenticationController: AuthenticationController! = nil
    var videoUrl = ""
    var videoPath = ""
    var selectedIndex = 0
    var videos = VideoSource.shared.allVideoModels
    var appConfiguration = AppConfiguration(
        clientIdentifier: Constants.Video.vimeoClientIdentifier,
        clientSecret: Constants.Video.vimeoClientSecret,
        scopes: [.Public, .Private], keychainService: "")
    
    init(_ view: VideoPlayerViewModelDelegate) {
        self.view = view
        VideoSource.shared.playerDelegate = self
    }
    
    func setupModels() {
        var allVideos = [Any] ()
        let similarChapters = self.getSimilarChapters()
        self.sectionModels.value.removeAll()
        guard let videoModel = self.videoModel.value else { return }
        allVideos.append(VideoDesriptionCellModel(video: videoModel.video))
        
        if !similarChapters.isEmpty {
            allVideos.append(SimilarSkillsCellModel(name: ""))
        }
        
        allVideos.append(contentsOf: similarChapters.map {VideoCellModel(video: $0)})
        let allAudiobooksSection = SectionModel(cellModels: allVideos)
        self.sectionModels.value = [allAudiobooksSection]
        self.view.reload()
    }
}

// MARK: Delegate- VideoPlayerViewControllerDelegate
extension VideoPlayerViewModel: VideoPlayerViewControllerDelegate {
    
    func getSimilarChapters() -> [Video] {
        var similarChapters = [Video]()
        guard let videoModel = self.videoModel.value else { return [] }
        let chapterIdArr = videoModel.videoidentifer.components(separatedBy: "-")
        if let chapterId = chapterIdArr.first {
           
            let chapterID = "\(chapterId)-"
            similarChapters = VideoManager.getChaptersOfId(chapterID: chapterID).filter { $0.identifer != videoModel.videoidentifer }
        }
        return similarChapters
    }
    
    func downloadVideo() {
        guard let videoModel = self.videoModel.value else { return }
        let videoPath = videoModel.downloadPath
        let chapterNumber = videoModel.chapterNumber
        let pathComponent = chapterNumber + Constants.Video.fileExtension
        self.videoModel.value?.video.downloadVideo(pathComponent: pathComponent, videoUrl: URL(fileURLWithPath: videoPath), downloadProgressed: {
            progress in
        }) {
            result in
        }
    }
    
    var sectionCount: Int {
        self.sectionModels.value.count
    }
    
    var isEmpty: Bool {
        self.sectionModels.value.isEmpty
    }
    
    func itemCount(section: Int) -> Int {
        self.sectionModels.value[section].cellModels.count
    }
    
    func section(at index: Int) -> SectionModel {
        self.sectionModels.value[index]
    }
   
    func cellModel(at indexPath: IndexPath) -> Any {
        self.sectionModels.value[indexPath.section].cellModels[indexPath.row]
    }
    
    func didSelectRow(at indexPath: IndexPath) {
        guard let model = self.sectionModels.value[indexPath.section].cellModels[indexPath.row] as? VideoCellModel else { return }
        for index in 0..<self.videos.count {
            if self.videos[index].video.identifer == model.video.identifer {
                self.selectedIndex = index
            }
        }
        self.videoModel.value = model
        self.setupModels()
        self.setupVimeoAuthentication()
    }
  
    func setupVimeoAuthentication() {
        
        self.vimeoClient = VimeoClient(appConfiguration: appConfiguration, configureSessionManagerBlock: nil)
        self.authenticationController = AuthenticationController(client: vimeoClient, appConfiguration: appConfiguration, configureSessionManagerBlock: nil)
        authenticationController.accessToken(token: Constants.Video.vimeoAccessToken) { [ weak self ] result in
            guard let self = self else { return }
            switch result {
            case .success(let account):
                self.createVideoURL() {
                    result in
                    if result {
                        self.view.loadVideo()
                    }
                }
            case .failure(let error):
                self.videoUrl = "error"
                self.videoPath = "error"
            }
        }
    }

    func downloadVideo(model: VideoDesriptionCellModel, indexPath: IndexPath) {
        guard let url = URL(string: model.downloadPath) else {return}
        let chapterNumber = model.chapterNumber
        let pathComponent = chapterNumber + Constants.Video.fileExtension
        model.updateDownload(value: DownloadState.downloading.rawValue)
        model.video.downloadVideo(pathComponent: pathComponent, videoUrl: url, downloadProgressed: { [weak self] progress in
            
            guard let self = self else { return }
            let downloadPercentage = progress.fractionCompleted
            let previous = model.currentPercentage.rounded(toPlaces: 1)
            let current = progress.fractionCompleted.rounded(toPlaces: 1)
            
            // Only update when just after 10% complete
            if current > previous {
                model.currentPercentage = downloadPercentage
                model.percentage = downloadPercentage
               
                // reload cell
                if self.view != nil{
                    self.view?.reloadRow(indexPath: indexPath)
                }
                
                // call Notifiy to update videochapterlist VC cell
                let progressValue = ["progressFraction": progress, "chapterIdentifier": model.chapterIdentifier]
                NotificationCenter.default.post(name: .loaderProgress, object: nil, userInfo: progressValue)
                
                
            }
        }) { [weak self] result in
            guard let self = self else { return }
            
            self.view.showFloatingMessage("\(model.chapterIdentifier) \(Text.downloadSuccessful.localize())", type: .downloaded)
            self.view?.reloadRow(indexPath: indexPath)
            self.view?.reload()
            
            // update videochapterlistVC
            let progressCompleted = ["result": result, "chapterIdentifier": model.chapterIdentifier]
            NotificationCenter.default.post(name: .loaderProgressCompleted, object: nil, userInfo: progressCompleted)
            
            
            // write realm code to make downloadpath = ""
        }
    }
    
    func updateBookMark(model: VideoDesriptionCellModel) {
        model.video.updateBookmark()
    }
    
    func updateBookMarkVideoCell(model: VideoCellModel) {
        // TO DO code
        model.updateBookmark()
        self.setupModels()
    }
    
    func deleteVideo(model: VideoDesriptionCellModel, indexPath: IndexPath) {
        VideoSource.shared.resetProgress(for: VideoCellModel(video: model.video))
        VideoManager.removeDownloadedVideo({ (success, error) in
            if success {
                self.view.showAlert("\(model.chapterIdentifier) \(Text.successfullyDeleted.localize())", type: .deleted)

//                self.view.showFloatingMessage("\(model.chapterIdentifier) \(Text.successfullyDeleted.localize())", type: .deleted)
            } else {
                if let error = error {
                    self.view.handleError(error.localizedDescription as! AnyError)
                }
            }
        }, chapterNumber: model.chapterNumber)
        self.view.reloadRow(indexPath: indexPath)
    }
    
    func deleteVideo(item: VideoCellModel, indexPath: IndexPath) {
        VideoSource.shared.resetProgress(for: item)
        VideoManager.removeDownloadedVideo({ (success, error) in
            if success {
                self.view.showAlert("\(item.chapterIdentifier) \(Text.successfullyDeleted.localize())", type: .deleted)
                
                //  self.view.showFloatingMessage("\(item.chapterIdentifier) \(Text.successfullyDeleted.localize())", type: .deleted)
                self.view.reloadRow(indexPath: indexPath)
            } else {
                if let error = error {
                    self.view?.handleError(error.localizedDescription as! AnyError)
                }
            }
        }, chapterNumber: item.chapterNumber)
        self.view.reloadRow(indexPath: indexPath)
    }
    
    func saveProgressedTime(lastProgressTime: Double) {
        self.videoModel.value?.video.updateProgressTime(lastProgressTime: lastProgressTime)
    }
    
    func didChangeVideo(sender: VersaStatefulButton?){
        authenticationController.accessToken(token: Constants.Video.vimeoAccessToken) { result in
            switch result {
            case .success(let account):
                print("authenticated successfully: \(account)")
                // play previous video
                if sender?.tag == 0 {
                    self.selectedIndex = self.selectedIndex == 0 ? self.selectedIndex : (self.selectedIndex - 1)
                    self.videoModel.value = self.videos[self.selectedIndex]
                    self.setupModels()
                    self.setupVimeoAuthentication()
                }
                
                if sender?.tag == 1 {
                    self.selectedIndex = (self.selectedIndex == self.videos.count - 1) ? self.selectedIndex : (self.selectedIndex + 1)
                    self.videoModel.value = self.videos[self.selectedIndex]
                    self.setupModels()
                    self.setupVimeoAuthentication()
                }
            case .failure(let error):
                self.view.didEndFetching()
                print("failure authenticating: \(error)")
            }
        }
    }
    
    func selectVideo(model: VideoCellModel, indexPath: IndexPath) {
        model.isSelected = !model.isSelected
        let videosCellModel =  self.sectionModels.value[indexPath.section].cellModels.filter { $0 is VideoCellModel }
            .map { $0 as? VideoCellModel }
        guard let model =  self.sectionModels.value[1].cellModels.filter({ $0 is DownloadContentCellModel }).first as? DownloadContentCellModel else { return }
        let selectedItems = videosCellModel.filter { $0?.isSelected == true }
        model.selectedCount = "\(selectedItems.count) \(Text.selected.localize())"
        self.view.reload()
    }
    
    func setupVimeoAuthenticationForDownload(model: VideoCellModel) {
        self.vimeoClient = VimeoClient(appConfiguration: appConfiguration, configureSessionManagerBlock: nil)
        self.authenticationController = AuthenticationController(client: vimeoClient, appConfiguration: appConfiguration, configureSessionManagerBlock: nil)
        authenticationController.accessToken(token: Constants.Video.vimeoAccessToken) { result in
            switch result {
            case .success(let account):
                print("authenticated successfully: \(account)")
                self.createVideoURL(model: model)
            case .failure(let error):
                self.videoUrl = "error"
                self.videoPath = "error"
                print("failure authenticating: \(error)")
            }
        }
    }
    
    func cancelDownload() {
        debugPrint("New VideoCellModel: cancelDownload")
    }
}

// MARK : = Create videoURL for similar videos played from list
extension VideoPlayerViewModel {
    
    func createVideoURL(completion: @escaping (Bool) -> Void) {
        self.view.didStartFetching()
        guard let videoModel = self.videoModel.value else { return }
        
        let videoRequest = Request<VIMVideo>(path: "/videos/\(videoModel.videoId)")
        vimeoClient.request(videoRequest) { result in
            switch (result) {
            case .success(let response):
                print("FETCH VIDEOS SUCCESS")
                //let video: VIMVideo = response.model
                let data = response.json
                let downloadBlock = data["download"] as! NSArray
                let downloadHd = downloadBlock[0] as! NSDictionary
                self.videoPath = downloadHd["link"] as! String
                self.videoUrl = "<iframe src=\"https://player.vimeo.com/video/\(videoModel.videoId)?badge=0&autopause=0&player_id=0&app_id=98974&playsinline=1\""
                
                //let realm = try! Realm()
                
                do {
                    // save the videopath in db to download the video later with the same path..
                    let realm = try Realm()
                    
                    // update fetched download path for selected video
                    try realm.write {
                        self.videoModel.value?.video.downloadPath = self.videoPath
                    }
                    completion(true)
                } catch {
                    print("Error while updating video's 'isDownloaded' state")
                }
            case .failure(let error):
                self.videoUrl = "error"
                self.videoPath = "error"
                print("FETCH VIDEOS ERROR")
                print("ERROR AUTHENTICATING \(error.localizedDescription)")
            }
        }
    }
    
    func createVideoURL(model: VideoCellModel) {
        let videoRequest = Request<VIMVideo>(path: "/videos/\(model.videoId)")
        vimeoClient.request(videoRequest) { result in
            switch (result) {
            case .success(let response):
                print("FETCH VIDEOS SUCCESS")
                //let video: VIMVideo = response.model
                let data = response.json
                let downloadBlock = data["download"] as! NSArray
                let downloadHd = downloadBlock[0] as! NSDictionary
                self.videoPath = downloadHd["link"] as! String
                print("url path for playing created ", model.video.downloadPath)
                
                self.videoUrl = "<iframe src=\"https://player.vimeo.com/video/\(model.videoId)?badge=0&autopause=0&player_id=0&app_id=98974&playsinline=1\""
                // save the videopath in db to download the video later with the same path..
                let realm = try! Realm()
                // update fetched download path for selected video
                do {
                    // persist fetched 'downloadPath' for selected video
                    try realm.write {
                        model.video.downloadPath = self.videoPath
                    }
                    guard let url = URL(string: model.downloadPath) else {return}
                    let chapterNumber = model.chapterNumber
                    let pathComponent = chapterNumber + Constants.Video.fileExtension
                    model.updateDownload(value: DownloadState.downloading.rawValue)
                    self.cancelDownload()
                    VideoSource.shared.downloadVideo(model: model, pathComponent: pathComponent, videoUrl: url)
                } catch {
                    print("Error while updating video's 'isDownloaded' state")
                }
            case .failure(let error):
                self.videoUrl = "error"
                self.videoPath = "error"
                print("FETCH VIDEOS ERROR")
                print("ERROR AUTHENTICATING \(error.localizedDescription)")
            }
        }
    }
}

extension VideoPlayerViewModel: VideoSourceDelegate {
    func didUpdate(progress: FileProgress, for model: VideoCellModel) {
        if let view = self.view {
            let cellModels = self.sectionModels.value[0].cellModels
            for cellModel in cellModels {
                if let cellM = cellModel as? VideoDesriptionCellModel, cellM.chapterIdentifier == model.chapterIdentifier {
                    let downloadPercentage = progress.fractionCompleted
                    cellM.currentPercentage = downloadPercentage
                    //                        model.chapterDownloading.value = true
                    cellM.percentage = downloadPercentage
                    view.reload()
                }
                
                if let cellM = cellModel as? VideoCellModel, cellM.chapterIdentifier == model.chapterIdentifier {
                    cellM.chapterDownloading.value = true
                    let downloadPercentage = progress.fractionCompleted
                    cellM.currentPercentage = downloadPercentage
                    //                        model.chapterDownloading.value = true
                    cellM.percentage = downloadPercentage
                    view.reload()
                }
                
            }
        }
    }
    
    func didFinishDownload(forModel model: VideoCellModel, result: Bool) {
        if let view = self.view {
            model.chapterDownloading.value = false
            view.showFloatingMessage("\(model.chapterIdentifier) \(Text.downloadSuccessful.localize())", type: .downloaded)
            self.setupModels()
        }
    }
}
