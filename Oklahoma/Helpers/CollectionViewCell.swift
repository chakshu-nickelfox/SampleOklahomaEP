//
//  CollectionViewCell.swift
//  Oklahoma
//
//  Created by Chakshu Dawara on 27/12/23.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {

    var item: Any? {
        didSet {
            self.configure(self.item)
        }
    }
    
    weak var delegate: NSObjectProtocol?
    
    func configure(_ item: Any?) {
        
    }
    
}

class CollectionReusableView: UICollectionReusableView {
    
    var item: Any? {
        didSet {
            self.configure(self.item)
        }
    }
    
    weak var delegate: NSObjectProtocol?
    
    func configure(_ item: Any?) {
        
    }
    
}
