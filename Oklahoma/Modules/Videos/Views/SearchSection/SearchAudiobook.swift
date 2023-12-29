//
//  SearchAudiobook.swift
//  BaseOklahoma
//
//  Created by Akanksha Trivedi on 15/02/23.
//  Copyright © 2023 Nickelfox. All rights reserved.
//

import UIKit

protocol Search: AnyObject {
    func searchFor(text: String)
    var searchingAudioBook: Bool { get set }
}

class SearchAudiobook: TableHeaderFooterView {
    
    @IBOutlet var searchAudiobook: UISearchBar!
    @IBOutlet weak var labelWidthConstariants: NSLayoutConstraint!
    @IBOutlet weak var lblTitle: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupSearchBar()
        searchAudiobook.delegate = self
        self.deviceType()
    }
    
    override func configure(_ item: Any?) {
        guard let model = item as? SearchTableHeaderViewModel else { return }
        searchAudiobook.placeholder = model.placeHolder
        lblTitle.text = UIDevice.isIPad ? model.searchTile: ""
    }
    
    func deviceType() {
        self.lblTitle.superview?.isHidden = !UIDevice.isIPad
     }
}

extension SearchAudiobook: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            (self.delegate as? Search)?.searchingAudioBook = false
        } else {
            (self.delegate as? Search)?.searchingAudioBook = true
        }
        
        // NOTE: gets the typed word from user or gets the blank
        //       text when click on cancel button or user clear the text field
        (self.delegate as? Search)?.searchFor(text: searchText)

    }
}

extension SearchAudiobook {
    func setupSearchBar() {
        searchAudiobook.setImage(UIImage(), for: .search, state: .normal)
        if let textfield = searchAudiobook.value(forKey: "searchField") as? UITextField {
            textfield.backgroundColor = Colors.secondaryDarkColor
            textfield.textColor = .white
            textfield.attributedPlaceholder = NSAttributedString(string: textfield.placeholder ?? "", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        }
    }
}

extension NSLayoutConstraint {
    /**
     Change multiplier constraint

     - parameter multiplier: CGFloat
     - returns: NSLayoutConstraint
    */
    func setMultiplier(multiplier:CGFloat) -> NSLayoutConstraint {

        NSLayoutConstraint.deactivate([self])

        let newConstraint = NSLayoutConstraint(
            item: firstItem,
            attribute: firstAttribute,
            relatedBy: relation,
            toItem: secondItem,
            attribute: secondAttribute,
            multiplier: multiplier,
            constant: constant)

        newConstraint.priority = priority
        newConstraint.shouldBeArchived = self.shouldBeArchived
        newConstraint.identifier = self.identifier

        NSLayoutConstraint.activate([newConstraint])
        return newConstraint
    }
}
