//
//  DownloadTableViewCell.swift
//  BaseOklahoma
//
//  Created by Akanksha Trivedi on 15/02/23.
//  Copyright © 2023 Nickelfox. All rights reserved.
//

import UIKit

protocol DownloadTableViewCellDelegate: AnyObject {
    func didTapDownloadAll(_ cell: DownloadTableViewCell)
}

class DownloadTableViewCell: TableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var selectionCountLabel: UILabel!
    
    private lazy var allVideos: [VideoCellModel] = {
        return VideoSource.shared.allVideoModels
    }()
    var isAllVideosDownloaded: Bool {
        return self.allVideos.allSatisfy({ $0.downloadState == .downloadComplete })
    }
    
    override func awakeFromNib() {
        self.setupUI()
    }
    
    func setupUI() {
        self.nameLabel.setFont(.m8)
        self.actionButton.setFont(.m8)
        self.selectionCountLabel.setFont(.m8)
    }
    
    override func configure(_ item: Any?) {
        guard let model = item as? DownloadContentCellModel else {
            return
        }
        self.nameLabel.text = model.title
        self.actionButton.setTitleColor(model.button.titleColor, for: .normal)
        switch model.button {
        case .download:
            self.actionButton.setImage(
                Images.All.downloadAll.image,
                for: .normal
            )
        case.delete:
            self.actionButton.setImage(
                Images.All
                    .deleteAllRed.image,
                for: .normal
            )
        case .cancel, .buy:
            self.actionButton.setImage(nil,for: .normal)
        case .cancelDownload:
            self.actionButton.setImage(model.button.buttonImage, for: .normal)
        }
        self.actionButton.setTitle(model.buttonTitle, for: .normal)
        self.actionButton.isHidden = model.hideActionButton
        self.selectionCountLabel.text = model.selectedCount
    }
    
    @IBAction func downloadAll(_ sender: UIButton) {
//        HapticFeedback.impact()
        (self.delegate as? DownloadTableViewCellDelegate)?.didTapDownloadAll(self)
    }
}
