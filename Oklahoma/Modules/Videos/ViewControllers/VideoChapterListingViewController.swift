//
//  VideoChapterListingViewController.swift
//  Oklahoma
//
//  Created by Chakshu Dawara on 27/12/23.
//

import UIKit
import VimeoNetworking
import Foundation
import RealmSwift
import ReactiveCocoa
import ReactiveSwift
import AVFoundation
import AVKit

typealias Handler = () -> Void

protocol VideoChapterListingViewControllerDelegate: AnyObject {
    var sectionCount: Int { get}
    var currentSection: Int { get}
    var isEmpty: Bool {get}
    func itemCount(section: Int) -> Int
    func section(at index: Int) -> SectionModel
    func cellModel(at indexPath: IndexPath) -> Any
    func didSelectRow(at indexPath: IndexPath)
    func reloadModels()
    func didSelectSegment(_ segment: ListSegment)
    func updateBookMark(model: VideoCellModel)
    var reloadHandler: Handler { get set }
    var selectedTab: ListSegment { get set }
    var isBookmarksEmpty: Bool { get }
    var isDownloadEmpty: Bool { get }
    func searchForVideo(text: String)
    func setupVimeoAuthenticationForDownload(model: VideoCellModel)
    func didSelectLastPlayed(video: Video)
    func deleteVideo(item: VideoCellModel)
    func updateBookmark()
    func selectAllVideos(model: DownloadContentCellModel, indexPath: IndexPath)
    func didDeselectAllVideos(section: Int)
    func selectVideo(model: VideoCellModel, indexPath: IndexPath)
    var floatingButtonType: ShowButton { get }
    var isAllChaptersSelected: MutableProperty<Bool> { get }
    func deleteAll()
    func downloadAll()
    func addVideoToLastPlayed(with identifier: String)
    func redirectToVideoPlayer(videoModel: VideoCellModel)
    //footer
    var emptySpaceFooterHeight: CGFloat { get }
    func footerHeight(section: Int) -> CGFloat
    func getEmptySpaceFooter(tableView: UITableView, section: Int) -> UIView?

    func cancelDownload()
    
    var isAllDownloadStart: Bool { set get }
    var isAllVideoEmpty: Bool { get }
    
    func didFinishDownload(result: Bool, chapterIdentifier: String)
    func didUpdate(progress: FileProgress, chapterIdentifier: String)
}

extension VideoChapterListingViewControllerDelegate {
    func reloadModels() {}
}

class VideoChapterListingViewController: UIViewController, UIPopoverPresentationControllerDelegate {
    
    static var isVideoPlayerVCVisible = false
    
    @IBOutlet weak var skillVideosHeadingButton: UIButton!
    @IBOutlet weak var videoChaptersTableView: UITableView!
    @IBOutlet weak var emptyLabel: UILabel!
    @IBOutlet weak var floatingButton: UIButton!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var emptyLabelBottomConstraint: NSLayoutConstraint!
    @objc var paidStatus = false
    @objc var videos: [VIMVideo] = []
    
    var appConfiguration = AppConfiguration(
        clientIdentifier: Constants.Video.vimeoClientIdentifier,
        clientSecret: Constants.Video.vimeoClientSecret,
        scopes: [.Public, .Private], keychainService: "")
    
    var searching:Bool = false
    var section: Int = 1
    var viewModel: VideoChapterListingViewControllerDelegate!
    
    @objc var titles = [String]()
    @objc var searchString = ""
    @objc var currentVideo: Video?
    
    // Setup Activity Indicator
    var activityIndicator = UIActivityIndicatorView()
    var strLabel = UILabel()
    let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    
    
    static var newInstance: VideoChapterListingViewController? {
        let sb = UIStoryboard.init(name: Storyboard.video.name,
                                   bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: self.className()) as? VideoChapterListingViewController
        return vc
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        for subView in view.subviews {
            if subView.accessibilityIdentifier == Constants.alert {
                if let floatAlertView = subView as? FloatAlertView {
                    floatAlertView.removeFromSuperview()
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = Text.skillVideos.localize()
        if self.viewModel == nil {
            self.viewModel = VideoChapterListingViewModel(self)
        }
        self.floatingButton.isHidden = true
        self.emptyLabel.setFont(.m4)
        self.setupObservers()
        self.viewModel.reloadHandler = { [weak self] in
            guard let this = self else { return }
            switch this.viewModel.selectedTab {
            case .all:
                let text: String
                let isHidden: Bool
                switch this.searchingAudiobook {
                case true:
                    text = Text.noVideoFound.localize()
                    isHidden = this.viewModel.itemCount(section: 1) == 0
                case false:
                    text = Text.noVideo.localize()
                    isHidden = this.viewModel.isAllVideoEmpty
                }
                
                this.emptyLabel.text = text
                this.emptyLabel.isHidden = !isHidden
            case .bookmarks:
                let text: String
                let isHidden: Bool
                switch this.searchingAudiobook {
                case true:
                    text = Text.noVideoFound.localize()
                    isHidden = this.viewModel.itemCount(section: 1) == 0
                case false:
                    text = Text.noBookmarksYet.localize()
                    isHidden = this.viewModel.isBookmarksEmpty
                }
                this.emptyLabel.text = text
                this.emptyLabel.isHidden = !isHidden
                this.floatingButton.isHidden = true
            case .downloads:
                let text: String
                let isHidden: Bool
                switch this.searchingAudiobook {
                case true:
                    text = Text.noVideoFound.localize()
                    isHidden = this.viewModel.itemCount(section: 1) == 0
                case false:
                    text = Text.noDownloadsYet.localize()
                    isHidden = this.viewModel.isDownloadEmpty
                }
                this.emptyLabel.text = text
                this.emptyLabel.isHidden = !isHidden
                this.floatingButton.isHidden = true
            }
        }
        self.setupTableView()
        NotificationCenter.default.addObserver(self, selector: #selector(playLastVideo(notification:)), name: .playLastVideo, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateProgress(notification:)), name: .loaderProgress, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateProgressCompleted(notification:)), name: .loaderProgressCompleted, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(downloadVideo(notification:)), name: .downloadVideo, object: nil)
    }
    
    @objc func playLastVideo(notification: NSNotification) {
        guard let model = notification.object as? Video else { return }
        print("going to player View", model)
        self.viewModel.addVideoToLastPlayed(with: model.identifer)
        let videoModel = VideoCellModel(video: model)
        
        if let videoVC = VideoPlayerViewController.newInstance {
            let viewModel = VideoPlayerViewModel(videoVC)
            videoVC.viewModel = viewModel
            viewModel.videoModel.value = videoModel
            self.presentVideoDetailView(videoVC)
        }
        print("going to player View")
    }
    
    @objc func updateProgress(notification: NSNotification) {
        if let dict = notification.userInfo as? [String: Any] {
               if let progressFraction = dict["progressFraction"] as? FileProgress, let chapterIdentifier = dict["chapterIdentifier"] as? String {
                   print(progressFraction)
                   print(chapterIdentifier)
                   self.viewModel.didUpdate(progress: progressFraction, chapterIdentifier: chapterIdentifier)
               }
           }
    }
    
    @objc func updateProgressCompleted(notification: NSNotification) {
        if let dict = notification.userInfo as? [String: Any] {
               if let result = dict["result"] as? Bool, let chapterIdentifier = dict["chapterIdentifier"] as? String {
                   self.viewModel.didFinishDownload(result: result, chapterIdentifier: chapterIdentifier)
               }
           }
    }
    
    @objc func downloadVideo(notification: NSNotification) {
           if let dict = notification.userInfo as? [String: Any] {
                  if let model = dict["model"] as? VideoDesriptionCellModel {
                      self.viewModel.setupVimeoAuthenticationForDownload(model: VideoCellModel(video: model.video))
                  }
              }
       }

    
    private func setupObservers() {
        
        self.viewModel.isAllChaptersSelected.signal.observeValues { selected in
            self.floatingButton.isHidden = false
            let button = self.viewModel.floatingButtonType
            switch button {
            case.buy, .cancel:
                self.floatingButton.isHidden = true
            case.delete:
                let buttonTitle = Text.deleteSelected.localize()
                self.floatingButton.setTitle(buttonTitle, for: .normal)
                self.floatingButton.backgroundColor = Colors.primaryRed
                self.floatingButton.setImage(UIImage(named: Images.All.delete.rawValue), for: .normal)
            case.download:
                let buttonTitle = selected ?  Text.downloadAll.localize(): Text.downloadSelected.localize()
                self.floatingButton.setTitle(buttonTitle, for: .normal)
                self.floatingButton.backgroundColor = Colors.primaryGreen
                self.floatingButton.setImage(UIImage(named: Images.All.downloadAllWhite.rawValue), for: .normal)
            case .cancelDownload:
                break
            }
        }
    }
    
    private func setupNavigationBar() {
        self.view.backgroundColor = Colors.secondaryDarkColor
        self.floatingButton.setFont(.m4)
        self.floatingButton.roundedCorner(radius: 8)
        self.navigationController?.navigationBar.isHidden = true
        self.navigationBar.isHidden = UIDevice.isIPad
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        NotificationCenter.default.post(name: .hideTabBar, object: false)
        self.skillVideosHeadingButton.setTitle(Text.skillVideos.localize(), for: .normal)
        self.setupNavigationBar()
        self.viewModel.didSelectSegment(.all)
        self.setupTableView()
        self.videoChaptersTableView.reloadData()
        // to reset the selection on the current section
        viewModel.didDeselectAllVideos(section: viewModel.currentSection)
        addKeyboardObserver()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
        self.removeKeyboardObserver()
    }
    
    @IBAction func didTapFloatingButton(_ sender: UIButton) {
        switch self.viewModel.floatingButtonType {
        case .delete:
            self.viewModel.deleteAll()
            self.viewModel.cancelDownload()
        case.download:
            self.viewModel.downloadAll()
            self.viewModel.cancelDownload()
            self.viewModel.isAllDownloadStart = true
        case .cancel, .buy:
            break
        case .cancelDownload:
            break
        }
        self.viewModel.didDeselectAllVideos(section: self.viewModel.currentSection)
        self.floatingButton.isHidden = true
    }
}

extension VideoChapterListingViewController {
    
    @objc private func addKeyboardObserver() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(handleKeyboardNotification),
            name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(
            self, selector: #selector(handleKeyboardNotification),
            name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func removeKeyboardObserver() {
        NotificationCenter.default.removeObserver(
            self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(
            self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
     
    @objc func handleKeyboardNotification(_ notification: Notification) {
        guard let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        let isKeyboardShowing = notification.name == UIResponder.keyboardWillShowNotification
        self.emptyLabelBottomConstraint?.constant = isKeyboardShowing ? (keyboardFrame.height + 20) : 150
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
    }
}

extension VideoChapterListingViewController: UITableViewDataSource, UITableViewDelegate {
    
    func setupTableView() {
        self.videoChaptersTableView.delegate = self
        self.videoChaptersTableView.dataSource = self
        self.videoChaptersTableView.estimatedRowHeight = self.view.bounds.height / 2
        self.videoChaptersTableView.rowHeight = UITableView.automaticDimension
        self.videoChaptersTableView.estimatedSectionHeaderHeight = 100
        self.videoChaptersTableView.sectionHeaderHeight = UITableView.automaticDimension
        self.videoChaptersTableView.sectionFooterHeight = CGFloat.leastNormalMagnitude
        self.videoChaptersTableView.registerHeaderFooter(SegmentTableHeaderView.self)
        self.videoChaptersTableView.registerCell(VideoChapterListingCell.self)
        self.videoChaptersTableView.registerHeaderFooter(SearchAudiobook.self)
        self.videoChaptersTableView.registerCell(VideoPlayedCell.self)
        self.videoChaptersTableView.registerCell(DownloadTableViewCell.self)
        
        let nib = UINib(nibName: "ChapterHeaderView", bundle: nil)
        self.videoChaptersTableView.register(nib, forHeaderFooterViewReuseIdentifier: "ChapterHeaderView")
        self.videoChaptersTableView.keyboardDismissMode = .onDrag
        self.videoChaptersTableView.separatorStyle = .none
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.viewModel.sectionCount
    }
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.itemCount(section: section)
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cellIdentifier = self.reusableIdentifiers(at: indexPath),
              let cell = tableView.dequeueReusableCell(
                withIdentifier: cellIdentifier) as? TableViewCell else {
            return UITableViewCell()
        }
        cell.row = indexPath.row
        let item = self.viewModel.cellModel(at: indexPath)
        cell.item = item
        if let cell = cell as? VideoChapterListingCell{
            cell.circularProgress.isHidden = true
        }
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView,
                   viewForHeaderInSection section: Int) -> UIView? {
        guard let model = self.viewModel.section(at: section).headerModel else {
            return nil
        }
        guard let sectionIdentifier = self.reusableSectionIdentifiers(at: section),
              let headerView = tableView.dequeueReusableHeaderFooterView(
                withIdentifier: sectionIdentifier) as? TableHeaderFooterView else { return nil }
        headerView.item = model
        headerView.delegate = self
        return headerView
    }
    
    private func reusableIdentifiers(at indexPath: IndexPath) -> String? {
        let cellModel = self.viewModel.cellModel(at: indexPath)
        switch cellModel {
        case is VideoCellModel:
            return VideoChapterListingCell.defaultReuseIdentifier
        case is DownloadContentCellModel:
            return DownloadTableViewCell.defaultReuseIdentifier
        case is VideoPlayedCellModel:
            return VideoPlayedCell.defaultReuseIdentifier
        default: return nil
        }
    }
    
    private func reusableSectionIdentifiers(at section: Int) -> String? {
        let headerModel = self.viewModel.section(at: section).headerModel
        switch headerModel {
        case is SegmentTableHeaderViewModel:
            return SegmentTableHeaderView.defaultReuseIdentifier
        case is SearchTableHeaderViewModel:
            return SearchAudiobook.defaultReuseIdentifier
        default: return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cellModel = self.viewModel.cellModel(at: indexPath)
        switch cellModel {
        case is VideoCellModel:
            return UITableView.automaticDimension
        default:
            return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let headerModel = self.viewModel.section(at: section).headerModel
        switch headerModel {
        case is SearchTableHeaderViewModel:
            return 50
        default:
            return UITableView.automaticDimension
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cellModel = self.viewModel.cellModel(at: indexPath)
        switch cellModel {
        case is VideoCellModel:
            self.viewModel.didSelectRow(at: indexPath)
        default:
            print("ok")
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return viewModel.footerHeight(section: section)
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        viewModel.getEmptySpaceFooter(tableView: tableView, section: section)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? VideoChapterListingCell else { return }
        let item = self.viewModel.cellModel(at: indexPath)
        cell.item = item
    }
}

extension VideoChapterListingViewController: VideoChapterListingViewModelDelegate {
 
    func showAlert(_ message: String, type: AlertType) {
        self.showFloatingMessage( message, type: .deleted)
    }
    
    func reloadRow(at indexPath: IndexPath?) {
        guard let indexPath = indexPath, let cell = videoChaptersTableView.cellForRow(at: indexPath) as? TableViewCell else { return }
        cell.configure(viewModel.cellModel(at: indexPath))
    }
    func reloadRow(row: Int) {
        let indexPosition = IndexPath(row: row, section: 1)
        self.videoChaptersTableView.reloadRows(at: [indexPosition], with: .none)
    }
    
    var searchingAudiobook: Bool {
        return self.searching
    }
    
    func reload() {
        self.videoChaptersTableView.reloadData()
    }
    
    func presentVideoDetailView(_ vc: VideoPlayerViewController) {
        guard let tabBarVC = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController else { return }
        tabBarVC.navigationItem.backButtonTitle = ""
        tabBarVC.navigationBar.isHidden = false
        tabBarVC.pushViewController(vc, animated: true)
    }

}

extension VideoChapterListingViewController: SegmentTableHeaderViewDelegate {
    
    func didSelectSegment(_ segment: ListSegment) {
        self.viewModel.didSelectSegment(segment)
            //this will reset the .all section list and hide the floating button
            self.viewModel.didDeselectAllVideos(section: viewModel.currentSection)
            viewModel.isAllChaptersSelected.value = false
    }
}

// MARK: Delegate- VideoChapterListingCellDelegate
extension VideoChapterListingViewController: VideoChapterListingCellDelegate {
    
    func handleSelection(_ cell: VideoChapterListingCell) {
        guard let model = cell.item as? VideoCellModel else { return }
        let indexPath = videoChaptersTableView.indexPath(for: cell)
        self.viewModel.selectVideo(model: model, indexPath: indexPath!)
    }
    
    func showFloatingSuccessMessage(identifier: String) {
        if !VideoChapterListingViewController.isVideoPlayerVCVisible {
            self.showFloatingMessage("\(identifier) \(Text.downloadSuccessful.localize())", type: .downloaded)
        }
    }

    func handleDownloadAction(_ cell: VideoChapterListingCell) {
        guard let model = cell.item as? VideoCellModel else { return }
        switch model.downloadState {
        case .notDownloaded:
            self.viewModel.setupVimeoAuthenticationForDownload(model: model)
            self.viewModel.cancelDownload()
        case .downloadComplete:
            self.viewModel.deleteVideo(item: model)
        case .downloading:
            print()
        case .none:
            print()
        case .downloadingPaused:
            print()
        }
    }
    
    func handleBookmarkAction(_ cell: VideoChapterListingCell) {
        guard let model = cell.item as? VideoCellModel else { return }
        self.viewModel.updateBookMark(model: model)
        if model.video.isBookmarked {
            self.showFloatingMessage("\(Text.chapter.localize()) \(model.row) \(Text.bookmarked.localize())", type: .bookmarked)
        } else {
            self.showFloatingMessage("\(Text.chapter.localize()) \(model.row) \(Text.bookmarkRemoved.localize())", type: .deleted)
        }
    }
}

extension VideoChapterListingViewController: VideoPlayedCellDelegate {
    
    func handleBookmark() {
        self.viewModel.updateBookmark()
    }
    
    func didSelectVideo(video: Video) {
        self.viewModel.didSelectLastPlayed(video: video)
    }
}

extension VideoChapterListingViewController: Search {
    var searchingAudioBook: Bool {
        get {
            return searching
        }
        set {
            self.searching = newValue
        }
    }
    
    func searchFor(text: String) {
        self.viewModel.searchForVideo(text: text)
    }
}


extension VideoChapterListingViewController: DownloadTableViewCellDelegate {
    
    func didTapDownloadAll(_ cell: DownloadTableViewCell) {
        guard let model = cell.item as? DownloadContentCellModel else { return }
        guard let indexPath = self.videoChaptersTableView.indexPath(for: cell) else {
            return
        }
        self.viewModel.selectAllVideos(model: model, indexPath: indexPath)
    }
}
