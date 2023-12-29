//
//  LastPlayedVideoCollectionViewCell.swift
//  BaseOklahoma
//
//  Created by Akanksha Trivedi on 15/02/23.
//  Copyright © 2023 Nickelfox. All rights reserved.
//

import UIKit
import FLUtilities

protocol LastPlayedVideoCollectionViewCellDelegate {
    func handleBookmarkAction()
}

class LastPlayedVideoCollectionViewCell: CollectionViewCell {
    
    
    @IBOutlet weak var bookmarkButton: BounceButton!
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var videoImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupUI()
        self.productImageView.layer.cornerRadius = 0
    }
    
    private func setupUI() {
        self.titleLabel.setFont(FontType.m3)
        self.subTitleLabel.setFont(FontType.m3)
    }
    
    override func configure(_ item: Any?) {
        
        if let item = item as? LastPlayedCellModel {
           self.titleLabel.text = item.title
            self.subTitleLabel.text = item.subtitle
            self.bookmarkButton.isLiked = item.bookmarked
            self.bookmarkButton.reaction = .bookmark
            self.checkBookmarkState(model: item)
            self.progressView.progress = Float(item.lastProgressTime)
            self.productImageView.image = UIImage(named: item.thumbnailImage)
        }
    }
    
    @IBAction func bookmarkPressed(_ sender: UIButton) {
        guard let button = sender as? BounceButton else { return }
        button.isLiked = !button.isLiked
        if button.isLiked {
//            HapticFeedback.success()
            button.flipLikedState()
        } else {
            button.flipWithoutAnimation()
        }
        if let item = self.item as? LastPlayedCellModel {
            item.updateBookmark()
            delay(0.2) {
                if let delegate = self.delegate as? LastPlayedVideoCollectionViewCellDelegate {
                    delegate.handleBookmarkAction()
                }
            }
        }
    }
    
    func checkBookmarkState(model: LastPlayedCellModel) {
        let bookmarkType: Images.All = model.bookmarked ? .bookmarked : .bookmark
        self.bookmarkButton.setImage(bookmarkType.image, for: .normal)
    }
}
