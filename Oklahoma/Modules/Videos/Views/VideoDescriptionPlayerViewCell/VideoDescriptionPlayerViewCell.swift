//
//  VideoDescriptionPlayerViewCell.swift
//  BaseOklahoma
//
//  Created by Akanksha Trivedi on 15/02/23.
//  Copyright © 2023 Nickelfox. All rights reserved.
//

import UIKit
import ReactiveSwift
import FLUtilities

protocol VideoDescriptionPlayerViewCellDelegate {
    func didTapDropDown()
    func handleBookmarkAction(_ cell: VideoDescriptionPlayerViewCell)
    func handleDownloadAction(_ cell: VideoDescriptionPlayerViewCell)
    
}

class VideoDescriptionPlayerViewCell: TableViewCell {
    
    @IBOutlet weak var circularProgress: CircularProgressView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bottomTitleLabel: UILabel!
    @IBOutlet weak var dropDownButton: UIButton!
    @IBOutlet weak var topContainerView: UIView!
    @IBOutlet weak var bottomContainerView: UIView!
    @IBOutlet weak var parentContainerView: UIStackView!
    
    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet weak var bookmarkButton: BounceButton!
    @IBOutlet weak var middleContainerView: UIView!
    
    private var isDropDownOpen = MutableProperty<Bool>(true)
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.downloadButton.isHidden = false
        self.circularProgress.isHidden = true
        self.downloadButton.setTitle("\(Text.download.localize())", for: .normal)
    }
    
    override func configure(_ item: Any?) {
        self.setupUI()
        guard let model = item as? VideoDesriptionCellModel else { return }
        self.titleLabel.text = model.chapterTitle
        self.bottomTitleLabel.attributedText = model.steps
        self.bottomContainerView.isHidden = !self.isDropDownOpen.value
        self.middleContainerView.isHidden = !self.isDropDownOpen.value
        self.circularProgress.trackClr = UIColor.white
        self.circularProgress.progressClr = UIColor.systemBlue
        self.checkDownloadState(model: model)
        self.checkBookmarkState(model: model)
    }
    
    func setupUI() {
        self.bookmarkButton.setTitle(Text.bookmark.localize(), for: .normal)
        self.bookmarkButton.reaction = .bookmark
        self.titleLabel.setFont(FontType.m4)
        self.bottomTitleLabel.setFont(FontType.m3)
        self.downloadButton.setFont(FontType.m4)
        self.bookmarkButton.setFont(FontType.m4)
        
        self.isDropDownOpen.signal.observeValues { result in
            if result == true {
                
                self.bottomTitleLabel.isHidden = false
                self.bottomContainerView.isHidden = false
                self.middleContainerView.isHidden = false
                
                UIView.animate(withDuration: 0.15) {
                    self.dropDownButton.setImage(UIImage(named: Images.All.dropDown.rawValue), for: .normal)
                }
                self.setNeedsLayout()
            } else {
                self.bottomContainerView.isHidden = true
                self.middleContainerView.isHidden = true
                
                self.setNeedsLayout()
            }
        }
    }
    
    func checkBookmarkState(model: VideoDesriptionCellModel) {
        let bookmarkType: Images.All = model.isBookmarked ? .bookmarked : .bookmark
        self.bookmarkButton.setImage(bookmarkType.image, for: .normal)
        self.bookmarkButton.isLiked = model.isBookmarked
    }
    
    func checkDownloadState(model: VideoDesriptionCellModel) {
        
        let bookmarkType: Images.All = model.downloadState == .notDownloaded ? .downloadAllWhite : .delete
        switch model.downloadState {
            
        case .notDownloaded, .downloadingPaused:
            self.downloadButton.isHidden = false
            self.circularProgress.isHidden = true
            self.downloadButton.setTitle("\(Text.download.localize())", for: .normal)
        case .downloading:
            self.downloadButton.isHidden = true
            self.circularProgress.isHidden = false
            DispatchQueue.main.async {
                self.circularProgress.setProgressWithAnimation(duration: 1.0, value: Float(model.currentPercentage))
            }
        case.downloadComplete:
            self.downloadButton.isHidden = false
            self.circularProgress.isHidden = true
            // once download is done then set the model download percentage to 0 so that animation start from zero when downloading again
            model.currentPercentage = 0.0
            self.circularProgress.setProgressWithAnimation(duration: 1.0, value: 0)
            self.downloadButton.setTitle("\(Text.delete.localize())", for: .normal)
        default:
            break
        }
        self.downloadButton.setImage(bookmarkType.image, for: .normal)
    }
    
    
    @IBAction func dropDownButtonActionAction(_ sender: UIButton) {
        self.isDropDownOpen.value = !self.isDropDownOpen.value
        if let delegate = self.delegate as? VideoDescriptionPlayerViewCellDelegate {
            delegate.didTapDropDown()
        }
    }
    
    
    @IBAction func bookmrkButtonAction(_ sender: Any) {
        
        guard let button = sender as? BounceButton else { return }
        button.isLiked = !button.isLiked
        if button.isLiked {
//            HapticFeedback.success()
            button.flipLikedState()
        } else {
            button.flipWithoutAnimation()
        }
        delay(0.2) {
            (self.delegate as? VideoDescriptionPlayerViewCellDelegate)?.handleBookmarkAction(self)
        }
    }
    
    
    @IBAction func downloadVideo(_ sender: UIButton) {
        (self.delegate as? VideoDescriptionPlayerViewCellDelegate)?.handleDownloadAction(self)
    }
}

