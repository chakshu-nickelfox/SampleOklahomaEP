//
//  VideoPlayedCell.swift
//  BaseOklahoma
//
//  Created by Akanksha Trivedi on 15/02/23.
//  Copyright © 2023 Nickelfox. All rights reserved.
//

import UIKit

protocol VideoPlayedCellDelegate: AnyObject {
    func didSelectVideo(video: Video)
    func handleBookmark()
}

extension VideoPlayedCellDelegate {
    func handleBookmark() {}
}

class VideoPlayedCell: TableViewCell {
    
    @IBOutlet weak var continueLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var cellModels: [Any] = []
    private let padding: CGFloat = 10
    
    override func awakeFromNib() {
        self.setupCollectionView()
        super.awakeFromNib()
        self.continueLabel.text = Text.continueWatching.localize()
        self.collectionView.collectionViewLayout = self.createCompositionalLayout()
    }
    
    override func configure(_ item: Any?) {
        if let item = item as? VideoPlayedCellModel {
            self.cellModels = item.videos
            self.collectionView.reloadData()
        }
    }
}

extension VideoPlayedCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    private func setupCollectionView() {
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.isPagingEnabled = false
        self.collectionView.registerCell(LastPlayedVideoCollectionViewCell.self)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(self.cellModels.count)
        return self.cellModels.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellIdentifier = LastPlayedVideoCollectionViewCell.defaultReuseIdentifier
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? CollectionViewCell
        else { return UICollectionViewCell() }
        
        cell.item = self.cellModels[indexPath.item]
        cell.delegate = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let item = self.cellModels[indexPath.item] as? LastPlayedCellModel,
           let delegate = self.delegate as? VideoPlayedCellDelegate {
            delegate.didSelectVideo(video: item.video)
        }
    }
}

extension VideoPlayedCell: LastPlayedVideoCollectionViewCellDelegate {
    func handleBookmarkAction() {
        if let delegate = self.delegate as? VideoPlayedCellDelegate {
            delegate.handleBookmark()
        }
    }
}

extension VideoPlayedCell {
    
    private func createCompositionalLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { (sectionNumber, env) -> NSCollectionLayoutSection? in
            return self.layoutSection()
        }
    }
    
    private func layoutSection() -> NSCollectionLayoutSection {
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(167.5), heightDimension: .absolute(150))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0)
        
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.contentInsets = .init(top: 0, leading: 20, bottom: 0, trailing: 0)
        group.interItemSpacing = .fixed(20)
        
       
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        
        return section
    }
}

