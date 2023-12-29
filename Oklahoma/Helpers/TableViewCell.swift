//
//  TableViewCell.swift
//  Oklahoma
//
//  Created by Chakshu Dawara on 25/12/23.
//

import UIKit

class TableViewCell: UITableViewCell {
    var row = 0
    var indexPath: IndexPath?
    var item: Any? {
        didSet {
            self.configure(self.item)
        }
    }

    weak var delegate: NSObjectProtocol?

    func configure(_ item: Any?) {
    }

}


class TableHeaderFooterView: UITableViewHeaderFooterView {

    var item: Any? {
        didSet {
            self.configure(self.item)
        }
    }

    weak var delegate: NSObjectProtocol?

    func configure(_ item: Any?) {

    }
    
}
