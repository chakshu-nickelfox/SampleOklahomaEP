//
//  VideoChapterListingViewModel.swift
//  Oklahoma
//
//  Created by Chakshu Dawara on 27/12/23.
//

import Foundation
import ReactiveSwift
import RealmSwift
import VimeoNetworking
import AnyErrorKit
import FLUtilities
import UIKit

protocol VideoChapterListingViewModelDelegate: BaseViewModelProtocol {
    func reload()
    func reloadRow(row: Int)
    func reloadRow(at indexPath: IndexPath?)
    func presentVideoDetailView(_ vc: VideoPlayerViewController)
    var  searchingAudiobook: Bool { get }
    func showFloatingSuccessMessage(identifier: String)
    func showAlert(_ message: String, type: AlertType)
}

class VideoChapterListingViewModel {
    
    private var sectionModels = MutableProperty<[SectionModel]>([])
    weak var view: VideoChapterListingViewModelDelegate!
    var reloadHandler: Handler = {}
    var disposable = CompositeDisposable([])
    var selectedTab = ListSegment.all
    var searching: Bool = false
    var searchVideos = [VideoCellModel]()
    var searchedText: String = ""
    var videoUrl = ""
    var videoPath = ""
    var vimeoClient: VimeoClient! = nil
    var currentButton = ShowButton.cancel
    var isAllChaptersSelected = MutableProperty(false)
    var authenticationController: AuthenticationController! = nil
    var appConfiguration = AppConfiguration(
        clientIdentifier: Constants.Video.vimeoClientIdentifier,
        clientSecret: Constants.Video.vimeoClientSecret,
        scopes: [.Public, .Private], keychainService: "")
    var downloadAllVideosStarted = false
    
    private lazy var allVideos: [VideoCellModel] = {
        return VideoSource.shared.allVideoModels
    }()
    var lastPlayedVideos = VideoSource.shared.allChapters
    var isBookmarksEmpty: Bool {
        return VideoSource.shared.allChapters.filter({$0.isBookmarked == true}).isEmpty
    }
    var isDownloadEmpty: Bool {
        return self.allVideos.filter({$0.downloadState == .downloadComplete}).isEmpty
    }
    var isAllDownloaded: Bool {
        return self.allVideos.allSatisfy({ $0.downloadState == .downloadComplete })
    }
    var isAllVideoEmpty: Bool {
        return self.allVideos.isEmpty
    }
    var dispatchQueue = DispatchQueue(label: "myQueue", qos: .background)
    var semaphore = DispatchSemaphore(value: 0)
    
    private var _isAllDownloadStart: Bool = false
    
    init(_ view: VideoChapterListingViewModelDelegate) {
        self.view = view
        VideoSource.shared.delegate = self
    }
    
    func setupModels(for segment: ListSegment) {
        var videos = [Any]()
        self.sectionModels.value.removeAll()
        VideoSource.shared.refreshAllVideos()
        if self.view?.searchingAudiobook == true {
            videos.append(contentsOf: searchVideos)
        } else {
            let titleString = Text.skillVideos.localize()
            switch segment {
            case .all:
                if isAllDownloaded {
                    videos.append(DownloadContentCellModel(
                        title: String(VideoSource.shared.allChapters.count) + " \(titleString)", buttonTitle: Text.deleteAll.localize(),
                        button: .delete,
                        buttonColor: Colors.primaryYellow,
                        selectedCount: 0,
                        hideActionButton: false))
                } else {
                    let ongoingDownloads = allVideos.filter({ $0.downloadState == .downloading })
                    let isDownloading = !ongoingDownloads.isEmpty
                    if (isDownloading || self.downloadAllVideosStarted) {
                        videos.append(DownloadContentCellModel(
                            title: String(VideoSource.shared.allChapters.count) + " \(titleString)",
                            //                            buttonTitle: ongoingDownloads.count == 1 ? Text.cancelDownload.localize() :
                            //                                Text.cancelDownloads.localize(),
                            buttonTitle: Text.cancelDownload.localize(),
                            button: .cancelDownload,
                            buttonColor: Colors.primaryYellow,
                            selectedCount: 0,
                            hideActionButton: false)
                        )
                    } else {
                        videos.append(DownloadContentCellModel(
                            title: String(VideoSource.shared.allChapters.count) + " \(titleString)",
                            buttonTitle: Text.downloadAll.localize(),
                            button: .download, buttonColor: Colors.primaryYellow,
                            selectedCount: 0,
                            hideActionButton: false)
                        )
                    }
                }
                videos.append(contentsOf: self.allVideos)
            case.bookmarks:
                self.isAllChaptersSelected.value = false
                let bookmarkedVideos = self.allVideos.filter({
                    return $0.isBookmarked == true
                })
                let count = bookmarkedVideos.count
                if count > 0 {
                    videos.append(DownloadContentCellModel(
                        title: String(count) + " \(titleString)",
                        buttonTitle: Text.deleteAll.localize(),
                        button: .cancel,
                        buttonColor: Colors.primaryYellow,
                        selectedCount: 0,
                        hideActionButton: true))
                }
                videos.append(contentsOf: bookmarkedVideos)
            case.downloads:
                self.isAllChaptersSelected.value = false
                let count = self.allVideos.filter({
                    return $0.downloadState == .downloadComplete
                }).count
                if count > 0 {
                    videos.append(DownloadContentCellModel(
                        title: String(count) + " \(titleString)",
                        buttonTitle: Text.deleteAll.localize(),
                        button: .delete,
                        buttonColor: Colors.primaryYellow,
                        selectedCount: 0,
                        hideActionButton: count == 1))
                }
                let downloadedVideos = self.allVideos.filter({
                    return $0.downloadState == .downloadComplete
                })
                videos.append(contentsOf: downloadedVideos)
            }
        }
        
        if self.getLastPlayedVideos().isEmpty {
            let newSection = SectionModel(headerModel: SearchTableHeaderViewModel(
                placeHolder: Text.searchVideoPlaceHolder.localize(),
                searchTile: Text.skillVideos.localize().capitalized),
                                          cellModels: [])
            self.sectionModels.value.append(newSection)
        } else {
            let cellModel = VideoPlayedCellModel(getLastPlayedVideos())
            let newSection = SectionModel(headerModel: SearchTableHeaderViewModel(
                placeHolder: Text.searchVideoPlaceHolder.localize(),
                searchTile: Text.skillVideos.localize().capitalized),
                                          cellModels: [cellModel])
            self.sectionModels.value.append(newSection)
        }
        
        // Get all videos
        let allAudiobooksSection = SectionModel(
            headerModel: SegmentTableHeaderViewModel(
                selectedSegment: self.selectedTab,
                segmentTitles: [Text.allVideos.localize(),
                                ListSegment.downloads.title,
                                ListSegment.bookmarks.title]
            ),
            cellModels: videos
        )
        self.sectionModels.value.append(allAudiobooksSection)
        self.reloadHandler()
        self.view.reload()
    }
    
    private func getLastPlayedVideos() -> [LastPlayedCellModel] {
        var cellModels = [LastPlayedCellModel]()
        let lastPlayedVideoIdentifiers = DataModel.shared.lastPlayedVideosIdentifiers
        
        let allVideos = VideoManager.getAllChapters()
        for identifier in lastPlayedVideoIdentifiers.suffix(5) {
            for video in allVideos {
                if video.identifer == identifier {
                    cellModels.append(LastPlayedCellModel(video))
                }
            }
        }
        return cellModels.reversed()
    }
}

//MARK: -  VC Functions
extension VideoChapterListingViewModel: VideoChapterListingViewControllerDelegate {
    
    func didFinishDownload(result: Bool, chapterIdentifier: String) {
        for sectiomModel in self.sectionModels.value {
            for cellModel in sectiomModel.cellModels {
                if let cellM = cellModel as? VideoCellModel, cellM.chapterIdentifier == chapterIdentifier {
                    cellM.chapterDownloading.value = false
                }
            }
        }
        if result {
            self.setupModels(for: self.selectedTab)
            self.view?.reload()
            self.view?.showFloatingMessage("\(chapterIdentifier) \(Text.downloadSuccessful.localize())", type: .downloaded)
        }
        if self.isAllDownloadStart {
            self.semaphore.signal()
        }
        self.view?.showFloatingSuccessMessage(identifier: chapterIdentifier)
        self.setupModels(for: self.selectedTab)
    }
    
    func didUpdate(progress: FileProgress, chapterIdentifier: String) {
        var sectionCount = -1
        var rowCount = -1
        for sectiomModel in self.sectionModels.value {
            sectionCount += 1
            for cellModel in sectiomModel.cellModels {
                rowCount += 1
                if let cellM = cellModel as? VideoCellModel, cellM.chapterIdentifier == chapterIdentifier {
                    cellM.chapterDownloading.value = true
                    let downloadPercentage = progress.fractionCompleted
                    cellM.currentPercentage = downloadPercentage
                    cellM.percentage = downloadPercentage
                    view.reload()
                }
            }
        }
    }
    
    
    var isAllDownloadStart: Bool {
        get {
            return _isAllDownloadStart
        }
        set(newValue) {
            self._isAllDownloadStart = newValue
        }
    }
    
    func cancelDownload() {
        guard let model =  self.sectionModels.value[1].cellModels.filter({ $0 is DownloadContentCellModel }).first as? DownloadContentCellModel else { return }
        
        if selectedTab == .all {
            
            let ongoingDownloads = allVideos.filter({ $0.downloadState == .downloading })
            if !ongoingDownloads.isEmpty { // is downloading something
                if selectedTab == .all {
                    model.buttonTitle = ongoingDownloads.count > 1 ? Text.cancelDownloads.localize() : Text.cancelDownload.localize()
                    model.button = .cancelDownload
                    model.buttonColor = .red
                }
            } else {
                if isAllDownloaded {
                    model.buttonTitle = Text.deleteAll.localize()
                    model.button = .delete
                    model.buttonColor = Colors.primaryYellow
                } else {
                    model.buttonTitle = Text.downloadAll.localize()
                    model.button = .download
                    model.buttonColor = Colors.primaryYellow
                }
            }
        } else {
            self.didDeselectAllVideos(section: self.currentSection)
        }
        self.currentButton = .cancel
        self.view.reload()
    }
    
    func addVideoToLastPlayed(with identifier: String) {
        var videosIdentifiers = DataModel.shared.lastPlayedVideosIdentifiers
        videosIdentifiers = videosIdentifiers.filter { $0 != identifier }
        videosIdentifiers.append(identifier)
        DataModel.shared.lastPlayedVideosIdentifiers = videosIdentifiers
    }
    
    func didDeselectAllVideos(section: Int) {
        let videosCellModel =  self.sectionModels.value[section].cellModels.filter { $0 is VideoCellModel }
            .map { $0 as? VideoCellModel }
        videosCellModel.forEach {
            $0?.isSelected = false
            $0?.isHidden = true
            $0?.hideDownloadButton = false
            $0?.aplha = 1.0
            $0?.userInterationEnabled = true
        }
        self.currentButton = .cancel
        self.setupModels(for: selectedTab)
        self.view.reload()
    }
    
    func selectVideo(model: VideoCellModel, indexPath: IndexPath) {
        model.isSelected = !model.isSelected
        let videosCellModel =  self.sectionModels.value[indexPath.section].cellModels.filter { $0 is VideoCellModel }
            .map { $0 as? VideoCellModel }
        if videosCellModel.allSatisfy({ $0?.isSelected == true}) {
            self.isAllChaptersSelected.value = true
        } else {
            self.isAllChaptersSelected.value = false
        }
        guard let model =  self.sectionModels.value[1].cellModels.filter({ $0 is DownloadContentCellModel }).first as? DownloadContentCellModel else { return }
        let selectedItems = videosCellModel.filter { $0?.isSelected == true }
        model.selectedCount = "\(selectedItems.count) \(Text.selected.localize())"
        self.view.reload()
    }
    
    func selectAllVideos(model: DownloadContentCellModel, indexPath: IndexPath) {
        let videosCellModel =  self.sectionModels.value[indexPath.section].cellModels.filter { $0 is VideoCellModel }
            .map { $0 as? VideoCellModel }
        guard let model =  self.sectionModels.value[1].cellModels.filter({ $0 is DownloadContentCellModel }).first as? DownloadContentCellModel else { return }
        
        switch model.button {
        case .delete:
            self.downloadAllVideosStarted = false
            model.buttonTitle = Text.cancel.localize()
            model.button = .cancel
            model.buttonColor = .red
            
            videosCellModel.forEach {
                $0?.isSelected = true
                $0?.isHidden = false
                $0?.hideDownloadButton = true
                if $0?.downloadState == .notDownloaded {
                    $0?.aplha = 0.4
                    $0?.userInterationEnabled = false
                }
            }
            model.selectedCount = "\(videosCellModel.count) \(Text.selected.localize())"
            self.currentButton = .delete
            
        case .download:
            self.downloadAllVideosStarted = true
            if isAllDownloadStart {
                self.view?.showFloatingMessage(
                    Text.downloadIsInProgress.localize(),
                    type: .downloaded)
                return
            }
            model.buttonTitle = Text.cancel.localize()
            model.button = .cancel
            self.isAllChaptersSelected.value = true
            videosCellModel.forEach {
                $0?.isSelected = $0?.downloadState != .downloadComplete
                $0?.isHidden = false
                $0?.hideDownloadButton = true
                if $0?.downloadState == .downloadComplete {
                    $0?.aplha = 0.4
                    $0?.userInterationEnabled = false
                }
            }
            let selectedItems = videosCellModel.filter { $0?.isSelected == true }
            model.selectedCount = "\(selectedItems.count) \(Text.selected.localize())"
            self.currentButton = .download
            
        case .cancel:
            self.downloadAllVideosStarted = false
            videosCellModel.forEach {
                $0?.isSelected = false
                $0?.isHidden = true
                $0?.hideDownloadButton = false
                $0?.aplha = 1.0
                $0?.userInterationEnabled = true
            }
            model.selectedCount = ""
            self.didDeselectAllVideos(section: self.currentSection)
            self.currentButton = .cancel
        case .buy:
            break
        case .cancelDownload:
            self.downloadAllVideosStarted = false
            if selectedTab == .all {
                videosCellModel.forEach {
                    $0?.isSelected = false
                    $0?.isHidden = true
                    $0?.hideDownloadButton = false
                    $0?.aplha = 1.0
                    $0?.userInterationEnabled = true
                    let chapterNumber = $0?.chapterNumber
                    let pathComponent = chapterNumber! + Constants.Video.fileExtension
                    $0?.video.cancelDownloadVideo(pathComponent: pathComponent)
                    if $0?.downloadState != .downloadComplete{
                        $0?.video.updateDownload(value: DownloadState.notDownloaded.rawValue)
                        $0?.video.updateDownloadPath(value: "")
                    }
                    $0?.chapterDownloading.value = false
                    $0?.percentage = 0.0
                    $0?.currentPercentage = 0.0
                }
                VideoSource.shared.cancelAllDownloads()
                self.didDeselectAllVideos(section: self.currentSection)
            } else {
                self.didDeselectAllVideos(section: self.currentSection)
            }
            self.currentButton = .cancelDownload
            self.isAllDownloadStart = false
            return
        }
        self.isAllChaptersSelected.value = true
        self.view.reload()
    }
    
    func searchForVideo(text: String) {
        
        var tempVideos: [VideoCellModel]
        switch self.selectedTab {
        case .all:
            tempVideos = self.allVideos
            
        case .bookmarks:
            tempVideos = self.allVideos.filter{ $0.isBookmarked }
            
        case .downloads:
            tempVideos = self.allVideos.filter{ $0.downloadState == .downloadComplete }
        }
        tempVideos = tempVideos.filter {
            $0.chapterTitle.lowercased().contains(text.lowercased()) ||
            $0.chapterIdentifier.lowercased().contains(text.lowercased())
        }
        self.searchVideos = tempVideos
        self.searchedText = text
        self.setupModels(for: self.selectedTab)
    }
    
    func updateBookMark(model: VideoCellModel) {
        model.updateBookmark()
        self.setupModels(for: self.selectedTab)
    }
    
    func didSelectSegment(_ segment: ListSegment) {
        self.selectedTab = segment
        switch segment {
        case .all, .downloads:
            print()
            currentButton = .cancel
            isAllChaptersSelected.value = false
        case .bookmarks:
            self.didDeselectAllVideos(section: self.currentSection)
        }
        
        if self.view?.searchingAudiobook == true {
            self.searchForVideo(text: self.searchedText)
        } else {
            self.setupModels(for: self.selectedTab)
        }
        
    }
    
    func reloadModels() {
        self.view.reload()
    }
    
    func didSelectRow(at indexPath: IndexPath) {
        guard let cellModel = self.sectionModels.value[indexPath.section].cellModels[indexPath.row] as? VideoCellModel else { return }
        self.addVideoToLastPlayed(with: cellModel.videoidentifer)
        self.redirectToVideoPlayer(videoModel: cellModel)
    }
    
    var sectionCount: Int {
        self.sectionModels.value.count
    }
    
    var currentSection: Int {
        if self.sectionModels.value.count == 1 {
            return 0
        } else {
            return 1
        }
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
        (self.sectionModels.value[indexPath.section].cellModels[indexPath.row] as? VideoCellModel)?.indexPath = indexPath
        let cellModel = self.sectionModels.value[indexPath.section].cellModels[indexPath.row]
        return cellModel
    }
    
    func updateBookmark() {
        self.setupModels(for: self.selectedTab)
    }
    
    var floatingButtonType: ShowButton {
        self.currentButton
    }
    
    func didSelectLastPlayed(video: Video) {
        self.addVideoToLastPlayed(with: video.identifer)
        let videoModel = VideoCellModel(video: video)
        if let videoVC = VideoPlayerViewController.newInstance {
            let viewModel = VideoPlayerViewModel(videoVC)
            videoVC.viewModel = viewModel
            viewModel.videoModel.value = videoModel
            viewModel.selectedIndex = index(of: videoModel, in: self.allVideos)
            self.view?.presentVideoDetailView(videoVC)
        }
    }
    
    func deleteVideo(item: VideoCellModel) {
        VideoManager.removeDownloadedVideo({ (success, error) in
            if success {
                // self.view.showAlert("\(item.chapterIdentifier) \(Text.successfullyDeleted.localize())", type: .deleted)
                self.view.showFloatingMessage("\(item.chapterIdentifier) \(Text.successfullyDeleted.localize())", type: .deleted)
                self.setupModels(for: selectedTab)
            } else {
                if let error = error {
                    self.view?.handleError(error.localizedDescription as! AnyError)
                }
            }
        }, chapterNumber: item.chapterNumber)
    }
    
    func deleteAll() {
        if (self.allVideos.allSatisfy { $0.isSelected == false }) {
        } else {
            let allSelectedVideos = self.allVideos.filter { $0.isSelected == true }
            for video in allSelectedVideos {
                VideoManager.removeDownloadedVideo({ (success, error) in
                    if success {
//                        self.view.showAlert(Text.filesDeleted.localize(), type: .deleted)
                        self.view.showFloatingMessage(Text.filesDeleted.localize(), type: .deleted)
                        self.setupModels(for: .all)
                    } else {
                        guard let error = error,
                              let anyError = error.localizedDescription as? AnyError
                        else { return }
                        self.view?.handleError( anyError )
                    }
                }, chapterNumber: video.chapterNumber)
            }
        }
    }
    
    func downloadAll() {
        self.downloadAllVideosStarted = true
        if (self.allVideos.allSatisfy { $0.isSelected == false }) {
        } else {
            // Download the selected video form the list
            let allSelectedVideos = self.allVideos.filter { $0.isSelected == true }
            let videos = allSelectedVideos.filter {
                $0.downloadState == .notDownloaded
            }
            if !allSelectedVideos.isEmpty {
                self.dispatchQueue = DispatchQueue(label: "myQueue", qos: .background)
                self.semaphore = DispatchSemaphore(value: 0)
                delay(0.1) {
                    self.dispatchQueue.async {
                        videos.forEach {
                            self.setupVimeoAuthenticationForDownload(model: $0)
                            self.semaphore.wait()
                        }
                        self.isAllDownloadStart = false
                    }
                }
            }
            
            if  self.isAllDownloaded {
                self.downloadAllVideosStarted = false
            }
        }
    }
    
    func setupVimeoAuthenticationForDownload(model: VideoCellModel) {
        self.vimeoClient = VimeoClient(appConfiguration: appConfiguration, configureSessionManagerBlock: nil)
        self.authenticationController = AuthenticationController(client: vimeoClient,
                                                                 appConfiguration: appConfiguration,
                                                                 configureSessionManagerBlock: nil)
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
    
    func redirectToVideoPlayer(videoModel: VideoCellModel) {
        if let videoVC = VideoPlayerViewController.newInstance {
            let viewModel = VideoPlayerViewModel(videoVC)
            videoVC.viewModel = viewModel
            viewModel.videoModel.value = videoModel
            viewModel.selectedIndex = index(of: videoModel, in: self.allVideos)
            self.view?.presentVideoDetailView(videoVC)
        }
    }
    
    func index(of: VideoCellModel, in array: [VideoCellModel]) -> Int {
        var index = 0
        for video in array {
            if video.videoId ==  of.videoId {
                return index
            }
            index += 1
        }
        return index
    }
    
    var emptySpaceFooterHeight: CGFloat { 100 }
    
    func footerHeight(section: Int) -> CGFloat {
        let sectionCount = self.sectionCount
        if section == sectionCount - 1 {
            return emptySpaceFooterHeight
        }
        return 0
    }
    
    func getEmptySpaceFooter(tableView: UITableView, section: Int) -> UIView? {
        // condition section
        let sectionCount = self.sectionCount
        if section == sectionCount - 1 {
            return UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: emptySpaceFooterHeight))
        }
        return nil
    }
}

//MARK: -  Download Video
extension VideoChapterListingViewModel {
    
    func createVideoURL(model: VideoCellModel) {
        let videoRequest = Request<VIMVideo>(path: "/videos/\(model.videoId)")
        vimeoClient.request(videoRequest) { result in
            switch (result) {
            case .success(let response):
                print("FETCH VIDEOS SUCCESS")
                // let video: VIMVideo = response.model
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

extension VideoChapterListingViewModel{
    func resetSection() {
        self.currentButton = .cancel
        self.isAllChaptersSelected.value = false
        didDeselectAllVideos(section: self.currentSection)
    }
}

extension VideoChapterListingViewModel: VideoSourceDelegate {
    func didUpdate(progress: FileProgress, for model: VideoCellModel) {
        var sectionCount = -1
        var rowCount = -1
        for sectiomModel in self.sectionModels.value {
            sectionCount += 1
            for cellModel in sectiomModel.cellModels {
                rowCount += 1
                if let cellM = cellModel as? VideoCellModel, cellM.chapterIdentifier == model.chapterIdentifier {
                    cellM.chapterDownloading.value = true
                    let downloadPercentage = progress.fractionCompleted
                    cellM.currentPercentage = downloadPercentage
                    cellM.percentage = downloadPercentage
                    view.reload()
                }
            }
        }
    }
    
    func didFinishDownload(forModel model: VideoCellModel, result: Bool) {
        model.chapterDownloading.value = false
        if result {
            self.setupModels(for: self.selectedTab)
            self.view?.reload()
            //            self.view?.showFloatingMessage("\(model.chapterIdentifier) \(Text.downloadSuccessful.localize())", type: .downloaded)
        }
        if self.isAllDownloadStart {
            self.semaphore.signal()
        }
        self.view?.showFloatingSuccessMessage(identifier: model.chapterIdentifier)
        self.setupModels(for: self.selectedTab)
    }
}
