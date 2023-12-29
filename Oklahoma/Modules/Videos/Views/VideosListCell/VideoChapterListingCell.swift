//
//  VideoChapterListingCell.swift
//  BaseOklahoma
//
//  Created by Akanksha Trivedi on 15/02/23.
//  Copyright © 2023 Nickelfox. All rights reserved.
//

import UIKit
import FLUtilities

protocol VideoChapterListingCellDelegate: AnyObject {
    func handleBookmarkAction(_ cell: VideoChapterListingCell)
    func handleDownloadAction(_ cell: VideoChapterListingCell)
    func handleSelection(_ cell: VideoChapterListingCell)
}

class VideoChapterListingCell: TableViewCell {
    
    @IBOutlet weak var circularProgress: CircularProgressView!
    @IBOutlet weak var chapterNumberLabel: UILabel!
    @IBOutlet weak var chapterTitleLabel: UILabel!
    @IBOutlet weak var chapterTimeLabel: UILabel!
    @IBOutlet weak var bookmarkButton: BounceButton!
    @IBOutlet weak var thumbnailImage: UIImageView!
    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet weak var selectButton: UIButton!
    @IBOutlet weak var imageDownloaded: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.imageDownloaded.isHidden = true
        hideDownloadBar()
    }
    
    override func configure(_ item: Any?) {
        guard let model = item as? VideoCellModel else { return }
        model.row = self.row
        self.chapterTitleLabel.text = model.chapterTitle
        self.chapterNumberLabel.text = model.chapterIdentifier
        self.chapterTimeLabel.text = model.totalVideosDuration
        self.bookmarkButton.isLiked = model.isBookmarked
        self.bookmarkButton.reaction = .bookmark
        self.checkBookmarkState(model: model)
        self.checkDownloadState(model: model)
        self.circularProgress.trackClr = UIColor.white
        self.circularProgress.progressClr = UIColor.systemBlue
        self.selectButton.isSelected = model.isSelected
        self.selectButton.isHidden =  model.isHidden
        self.downloadButton.isHidden = model.hideDownloadButton
        self.thumbnailImage.image = UIImage(named: model.thumbnailImage) ?? UIImage(named: "video_thumbnail_placeholder")
        self.contentView.alpha = model.aplha
        self.isUserInteractionEnabled =  model.userInterationEnabled
        if model.downloadState == .downloading {
            self.circularProgress.setProgressWithAnimation(duration: 1.0, value: Float(model.currentPercentage))
            self.circularProgress.isHidden = false
            self.downloadButton.isHidden = true
            self.circularProgress.superview?.layoutSubviews()
        } else {
            self.hideDownloadBar()
        }
    }
    
    
    func checkBookmarkState(model: VideoCellModel) {
        let bookmarkType: Images.All = model.isBookmarked ? .bookmarked : .bookmark
        self.bookmarkButton.setImage(bookmarkType.image, for: .normal)
    }
    
    func checkDownloadState(model: VideoCellModel) {
        
        let bookmarkType: Images.All = model.downloadState == .notDownloaded ? .downloadAll : .delete
        switch model.downloadState {
            
        case .notDownloaded, .downloadingPaused:
            self.circularProgress.isHidden = true
        case .downloading:
            self.downloadButton.isHidden = true
        case .downloadComplete:
            self.circularProgress.isHidden = true
            self.downloadButton.isHidden = false
            // once download is done then set the model download percentage to 0 so that animation start from zero when downloading again
            model.currentPercentage = 0.0
            self.circularProgress.setProgressWithAnimation(duration: 1.0, value: 0)
        default:
            self.downloadButton.isHidden = false
            break
        }
        if model.downloadState != .downloading{
            self.downloadButton.setImage(bookmarkType.image, for: .normal)
        }
        self.imageDownloaded.isHidden = model.downloadState != .downloadComplete
    }
    
    func setupUI() {
        self.chapterNumberLabel.setFont(FontType.h1)
        self.chapterTitleLabel.setFont(FontType.p2)
        self.chapterTimeLabel.setFont(FontType.p2)
        self.thumbnailImage.roundedCorner(radius: 0)
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
            (self.delegate as? VideoChapterListingCellDelegate)?.handleBookmarkAction(self)
        }
    }
    
    @IBAction func downloadAction(_ sender: Any) {
        (self.delegate as? VideoChapterListingCellDelegate)?.handleDownloadAction(self)
    }
    
    
    @IBAction func playAction(_ sender: UIButton) {
        (self.delegate as? VideoChapterListingCellDelegate)?.handleSelection(self)
    }
}

extension VideoChapterListingCell{
    
    func hideDownloadBar(){
        self.circularProgress.isHidden = true
    }
}
