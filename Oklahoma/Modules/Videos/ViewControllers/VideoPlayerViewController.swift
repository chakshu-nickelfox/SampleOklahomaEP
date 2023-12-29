//
//  VideoPlayerViewController.swift
//  Oklahoma
//
//  Created by Chakshu Dawara on 27/12/23.
//

import UIKit
import VimeoNetworking
import Foundation
import RealmSwift
import StoreKit
import AVFoundation
import MediaPlayer
import AVKit
import VersaPlayer
import ReactiveSwift
import FLUtilities

protocol VideoPlayerViewControllerDelegate: AnyObject {
    
    var  sectionCount: Int { get}
    var  isEmpty: Bool {get}
    func itemCount(section: Int) -> Int
    func section(at index: Int) -> SectionModel
    func cellModel(at indexPath: IndexPath) -> Any
    func didSelectRow(at indexPath: IndexPath)
    var  videoModel: MutableProperty<VideoCellModel?> { get }
    func setupVimeoAuthentication()
    func setupModels()
    func downloadVideo(model: VideoDesriptionCellModel, indexPath: IndexPath)
    
    func updateBookMark(model: VideoDesriptionCellModel)
    func updateBookMarkVideoCell(model: VideoCellModel)
    
    func deleteVideo(model: VideoDesriptionCellModel, indexPath: IndexPath)
    func deleteVideo(item: VideoCellModel, indexPath: IndexPath)
    
    func saveProgressedTime(lastProgressTime: Double)
    func didChangeVideo( sender: VersaStatefulButton?)
    
    func selectVideo(model: VideoCellModel, indexPath: IndexPath)
    func setupVimeoAuthenticationForDownload(model: VideoCellModel)
    func cancelDownload()
}

protocol VideoPlayerVCDownloadVideoDelegate: AnyObject {
    func downlaodVideo(model: VideoDesriptionCellModel)
}


class VideoPlayerViewController: UIViewController, UIWebViewDelegate, UIPopoverPresentationControllerDelegate {
    @IBOutlet weak var similerVideosTableView: UITableView!
    @IBOutlet weak var playerViewControls: UIStackView!
    @IBOutlet weak var playerView: HazmatVersaPlayer!
    @IBOutlet weak var controls: VersaPlayerControls!
    @IBOutlet weak var replayButton: VersaStatefulButton!
    @IBOutlet weak var forwardButton: VersaStatefulButton!
    @IBOutlet weak var backwardButton: VersaStatefulButton!
    @IBOutlet weak var offlineView: UIView!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var chapterNumberLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    var viewModel: VideoPlayerViewControllerDelegate!
    weak var delegate: VideoPlayerVCDownloadVideoDelegate!
    var activityIndicator: UIActivityIndicatorView!
    var orientations = UIInterfaceOrientationMask.landscapeLeft
   
    static var newInstance: VideoPlayerViewController? {
        let sb = UIStoryboard.init(name: Storyboard.video.name,
                                   bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: self.className()) as? VideoPlayerViewController
        return vc
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .overFullScreen
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        get { return self.orientations }
        set { self.orientations = newValue }
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
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        if self.viewModel == nil {
            self.viewModel = VideoPlayerViewModel(self)
        }
        self.setupNavigationBarControls()
        self.viewModel.setupVimeoAuthentication()
        self.viewModel.setupModels()
        self.setupNotifications()
        self.setupTableView()
        self.playerView.use(controls: controls)
        self.loadInputViews()
        self.setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(true)
        NotificationCenter.default.post(name: .hideTabBar, object: true)
        self.setupNavigationBarControls()
        errorLabel.isHidden = true
        VideoChapterListingViewController.isVideoPlayerVCVisible = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.savePlayedTime()
        VideoChapterListingViewController.isVideoPlayerVCVisible = false
    }
    
    func setupUI() {
        self.activityIndicator = Utilities().setUpActivityIndicator(self.view.frame.width, frameHeight: self.view.frame.height)
        self.forwardButton?.addTarget(self, action: #selector(playselectedItem), for: .touchUpInside)
        self.backwardButton?.addTarget(self, action: #selector(playselectedItem), for: .touchUpInside)
        replayButton?.addTarget(self, action: #selector(playVideoOnLoop), for: .touchUpInside)
        self.controls.fullscreenButton?.addTarget(self, action: #selector(setDeviceOrientation), for: .touchUpInside)
        self.navigationController?.view.addSubview(self.activityIndicator)
        self.navigationController?.view.bringSubviewToFront(self.activityIndicator)
        self.activityIndicator.style = UIActivityIndicatorView.Style.white
        replayButton.setImage(Images.All.replay.image , for: .normal)
        
        replayButton.setImage(Images.All.replay.image?.withTintColor(Colors.primaryYellow) , for: .selected)
        
    }
    
    func setupNavigationBarControls() {
        self.navigationController?.navigationBar.isHidden = true
        let backButton = UIBarButtonItem(image: UIImage(named: Images.All.goBack.rawValue), style: .plain, target: self, action: #selector(goBack))
        self.navigationItem.leftBarButtonItem  = backButton
    }
    
    func setupNotifications() {
        NotificationCenter.default.post(name: .pauseAudio, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidEndBufferingVideo(_:)),
                                               name: VersaPlayer.VPlayerNotificationName.endBuffering.notification,
                                               object: nil)
        self.playerView.player.addObserver(self, forKeyPath: "rate", options: NSKeyValueObservingOptions.new, context: nil)
    }
    
    @IBAction func goBack(_ sender: UIButton) {
        
        if  self.playerView.isFullscreenModeEnabled {
            self.toggleOrientation()
            self.controls.toggleFullscreen(sender: self.controls.fullscreenButton)
            self.playerView.isFullscreenModeEnabled = false
        } else {
            delay(0.75) {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    
// MARK: -  IB Action on PlayerView
    // loop button action and checking state.
    @IBAction func playVideoOnLoop(sender: VersaStatefulButton) {
        sender.isSelected = !sender.isSelected
    }
    
    @IBAction func playselectedItem(sender: VersaStatefulButton? = nil) {
        self.didStartFetching()
        self.replayButton.isSelected = false
        self.playerView.player.pause()
        self.viewModel.didChangeVideo(sender: sender)
    }
    
    // use this func for looping on the video
    @objc func playerDidFinishPlaying(note: NSNotification) {
        self.playerView.player.seek(to: .zero)
        if replayButton.isSelected{
            self.playerView.player.play()
        }
    }
    
    @objc func playerDidEndBufferingVideo(_ notification: NSNotification) {
        self.didEndFetching()
    }
    
    
    @objc func playerDidStartPlaying(_ notification: NSNotification) {
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        if object as AnyObject? === self.playerView.player {
            if keyPath == "rate" {
                if self.playerView.player.timeControlStatus == .paused {
                    let currentTime = self.playerView.player.currentItem?.currentTime().seconds
                    let duration =  self.playerView.player.currentItem?.duration.seconds
                    let value: Float =  Float(currentTime!/duration!)
                    self.viewModel.saveProgressedTime(lastProgressTime: Double(value))
                }
            }
        }
        if keyPath == "bounds" {
            let rect = change?[.newKey] as! NSValue
            if let playerRect: CGRect = rect.cgRectValue as? CGRect {
                if playerRect.size == UIScreen.main.bounds.size {
                    print("Player entered in full screen")
                } else {
                    print("Player not in full screen")
                    if(UIApplication.shared.isIgnoringInteractionEvents)
                    {print("ignoring")
                    }
                }
            }
        }
    }
    
    @objc func setDeviceOrientation(_ orientation: UIInterfaceOrientation) {
        toggleOrientation()
    }
    
    func toggleOrientation() {
        guard !UIDevice.isIPad else {
            return
        }
        
        let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
        let value: UIInterfaceOrientation
        
        if UIWindow.isLandscape {
            appDelegate.restrictRotation = .portrait
            value = .portrait
        } else {
            appDelegate.restrictRotation = .landscapeLeft
            value = UIInterfaceOrientation.landscapeLeft
        }
        
        UIDevice.current.setValue(value.rawValue, forKey: "orientation")
        VideoPlayerViewController.attemptRotationToDeviceOrientation()
    }
}
// MARK: - Similar Videos TableView

extension VideoPlayerViewController: UITableViewDataSource, UITableViewDelegate {
    
    func setupTableView() {
        self.similerVideosTableView.delegate = self
        self.similerVideosTableView.dataSource = self
        self.similerVideosTableView.estimatedRowHeight = self.view.bounds.height / 2
        self.similerVideosTableView.rowHeight = UITableView.automaticDimension
        self.similerVideosTableView.registerCell(VideoChapterListingCell.self)
        self.similerVideosTableView.registerCell(VideoDescriptionPlayerViewCell.self)
        self.similerVideosTableView.registerCell(SimilarVideoCell.self)
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
        let item = self.viewModel.cellModel(at: indexPath)
        cell.item = item
        cell.delegate = self
        
        if let item = item as? VideoCellModel {
            item.indexPath = indexPath
        }
        return cell
    }
    
    private func reusableIdentifiers(at indexPath: IndexPath) -> String? {
        let cellModel = self.viewModel.cellModel(at: indexPath)
        switch cellModel {
        case is VideoCellModel:
            return VideoChapterListingCell.defaultReuseIdentifier
        case is SimilarSkillsCellModel:
            return SimilarVideoCell.defaultReuseIdentifier
        case is VideoDesriptionCellModel:
            return VideoDescriptionPlayerViewCell.defaultReuseIdentifier
        default: return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cellModel = self.viewModel.cellModel(at: indexPath)
        switch cellModel {
        case is SimilarSkillsCellModel:
            return 60
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
            print()
        }
    }
}

// MARK: Delegate- VideoDescriptionPlayerViewCellDelegate
extension VideoPlayerViewController: VideoDescriptionPlayerViewCellDelegate {
    
    func didTapDropDown() {
        UIView.animate(withDuration: 0.15) {
            self.similerVideosTableView.performBatchUpdates(nil, completion: nil)
        }
    }
    
    func handleBookmarkAction(_ cell: VideoDescriptionPlayerViewCell) {
        guard let model = cell.item as? VideoDesriptionCellModel else { return }
        self.viewModel.updateBookMark(model: model)
    }
    
    func handleDownloadAction(_ cell: VideoDescriptionPlayerViewCell) {
        guard let indexPath = self.similerVideosTableView.indexPath(for: cell) else { return }
        guard let model = cell.item as? VideoDesriptionCellModel else { return }
        switch model.downloadState {
        case .notDownloaded:
            // self.viewModel.downloadVideo(model: model, indexPath: indexPath)
            
            
            // new code
            // call protocol on VideoChapterListingVC
            // self.delegate?.downlaodVideo(model: model)
            
            // new code
            // fire notification to download video on VideoChapterListingVC
            let downloadModel = ["model": model]
            NotificationCenter.default.post(name: .downloadVideo, object: nil, userInfo: downloadModel)
            
        case .downloadComplete:
            self.viewModel.deleteVideo(model: model, indexPath: indexPath)
        case .downloading,.downloadingPaused, .none:
            print()
        }
    }
    
    func reloadRow(indexPath: IndexPath) {
        self.similerVideosTableView.reloadRows(at: [indexPath], with: .none)
    }
}

extension VideoPlayerViewController: VideoPlayerViewModelDelegate {
    
    func showAlert(_ message: String, type: AlertType) {
        self.showFloatingMessage( message, type: .deleted)
    }
    
    func reload() {
        self.similerVideosTableView.reloadData()
    }
    
    func didStartFetching() {
        self.view.isUserInteractionEnabled = false
        self.playerViewControls.isHidden = true
        self.controls.showBuffering()
    }
    
    func didEndFetching() {
        self.view.isUserInteractionEnabled = true
        self.playerViewControls.isHidden = false
        self.controls.hideBuffering()
    }
    
    func loadVideo() {
        guard let videoModel = self.viewModel.videoModel.value else { return }
        self.chapterNumberLabel.text = videoModel.chapterIdentifier
        let urlString = videoModel.downloadPath
        var fileURL: URL?
        if videoModel.downloadState == .downloadComplete {
            guard let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
            let pathComponent = "/\(videoModel.chapterNumber).mp4"
            let path = documentsURL.path + pathComponent
            if FileManager.default.fileExists(atPath: (path)) {
                fileURL = URL(fileURLWithPath: (path))
            } else {
                self.showAlert(message: "Unable to load the video offline.")
                return
            }
        }
        // play video online
        else {
            fileURL = URL(string: (urlString))
        }
        guard let filePath = fileURL else { return }
        if !self.offlineView.contains(self.offlineView) {
            self.offlineView.addSubview(self.playerView)
            self.offlineView.bringSubviewToFront(self.playerView)
        }
        print("the file path is ", filePath)
        let item = VersaPlayerItem(url: filePath)
        self.playerView.set(item: item)
        self.playerView.playbackDelegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying(note:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: item)
    }
}

// MARK: Delegate- Player methods
extension VideoPlayerViewController {
    
    func loadInputViews() {
        // update screen title when moving to next or previous video
        let label = UILabel()
        label.text = Text.skill.localize()
        label.textAlignment = .left
        self.navigationItem.titleView = label
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.superview?.addConstraint(NSLayoutConstraint(item: label,
                                                          attribute: .centerX, relatedBy: .equal, toItem: label.superview,
                                                          attribute: .centerX,
                                                          multiplier: 1,
                                                          constant: -100))
        
        label.superview?.addConstraint(NSLayoutConstraint(item: label,
                                                          attribute: .width,
                                                          relatedBy: .equal, toItem: label.superview,
                                                          attribute: .width,
                                                          multiplier: 1,
                                                          constant: 0))
        
        label.superview?.addConstraint(NSLayoutConstraint(item: label, attribute: .centerY,
                                                          relatedBy: .equal,
                                                          toItem: label.superview,
                                                          attribute: .centerY,
                                                          multiplier: 1,
                                                          constant: 0))
        
        label.superview?.addConstraint(NSLayoutConstraint(item: label,
                                                          attribute: .height,
                                                          relatedBy: .equal,
                                                          toItem: label.superview,
                                                          attribute: .height,
                                                          multiplier: 1,
                                                          constant: 0))
        if self.playerView.controls != nil {
            if AppDelegate.shared?.viewControllerOrientation == 1 {
                // force update video player's screen mode
                self.playerView.isFullscreenModeEnabled = true
                self.controls.toggleFullscreen(sender: self.controls.fullscreenButton)
            }
        }
    }
    
    func savePlayedTime() {
        
        if let currentTime = self.playerView.player.currentItem?.currentTime().seconds, let duration = self.playerView.player.currentItem?.duration.seconds {
            let value: Float =  Float(currentTime/duration)
            self.viewModel.saveProgressedTime(lastProgressTime: Double(value))
        }
        self.playerView.player.replaceCurrentItem(with: nil)
    }
}

extension VideoPlayerViewController: VersaPlayerPlaybackDelegate{
    
    func playbackReady(player: VersaPlayer) {
        print(#function)
        guard let videoModel = self.viewModel.videoModel.value else { return }
        let seconds = (videoModel.video.lastProgressTime) * (player.currentItem?.asset.duration.seconds ?? 0)
        let time =  CMTime(seconds: seconds , preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        self.playerView.player.seek(to: time)
    }
}

// MARK: Delegate- VideoChapterListingCellDelegate
extension VideoPlayerViewController: VideoChapterListingCellDelegate {
    
    func handleSelection(_ cell: VideoChapterListingCell) {
        guard let model = cell.item as? VideoCellModel else { return }
        let indexPath = similerVideosTableView.indexPath(for: cell)
        self.viewModel.selectVideo(model: model, indexPath: indexPath!)
    }
    
    func showFloatingSuccessMessage(identifier: String) {
        self.showFloatingMessage("\(identifier) \(Text.downloadSuccessful.localize())", type: .downloaded)
    }
    
    func handleDownloadAction(_ cell: VideoChapterListingCell) {
        
        guard let model = cell.item as? VideoCellModel else { return }
        guard let indexPath = model.indexPath else { return }
        switch model.downloadState {
        case .notDownloaded:
            self.viewModel.setupVimeoAuthenticationForDownload(model: model)
            self.viewModel.cancelDownload()
        case .downloadComplete:
            self.viewModel.deleteVideo(item: model, indexPath: indexPath)
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
        self.viewModel.updateBookMarkVideoCell(model: model)
    }
}

class HazmatVersaPlayer: VersaPlayerView {
    
    override func setFullscreen(enabled: Bool) {
        super.setFullscreen(enabled: enabled)
        
        if enabled {
            AppDelegate.AppUtility.lockOrientation(UIInterfaceOrientationMask.portrait, andRotateTo: UIInterfaceOrientation.landscapeLeft)
        } else {
            if UIDevice.isIPad {
                AppDelegate.AppUtility.lockOrientation(UIInterfaceOrientationMask.all)
            } else {
                AppDelegate.AppUtility.lockOrientation(UIInterfaceOrientationMask.portrait, andRotateTo: UIInterfaceOrientation.portrait)
            }
        }
    }
}
