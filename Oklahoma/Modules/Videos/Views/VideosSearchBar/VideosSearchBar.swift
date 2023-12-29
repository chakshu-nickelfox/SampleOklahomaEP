//
//  VideosSearchBar.swift
//  BaseOklahoma
//
//  Created by Akanksha Trivedi on 15/02/23.
//  Copyright © 2023 Nickelfox. All rights reserved.
//

import UIKit

class VideosSearchBar: UISearchBar {
    
    @objc var preferredFont: UIFont!
    @objc var preferredTextColor: UIColor!
    
    @objc init(frame: CGRect, font: UIFont, textColor: UIColor) {
        super.init(frame: frame)
        self.frame = frame
        preferredFont = font
        preferredTextColor = textColor
        searchBarStyle = UISearchBar.Style.prominent
        isTranslucent = false
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func indexOfSearchFieldInSubviews() -> Int! {
        var index: Int!
        let searchBarView = subviews[0] 
        
        for i in 0..<searchBarView.subviews.count {
            if searchBarView.subviews[i].isKind(of: UITextField.self) {
                index = i
                break
            }
        }
        
        return index
    }
    

    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Find the index of the search field in the search bar subviews.
        if let index = indexOfSearchFieldInSubviews() {
            // Access the search field
            let searchField: UITextField = (subviews[0]).subviews[index] as! UITextField
            
            // Set its frame.
            searchField.frame = CGRect(x: 10.0, y: 10.0, width: frame.size.width-20, height: frame.size.height-20)
        
            // Set the font and text color of the search field.
            searchField.font = preferredFont
            searchField.textColor = UIColor.black
            
            // Set the background color of the search field.
            searchField.backgroundColor = UIColor.gray
            searchField.keyboardAppearance = UIKeyboardAppearance.dark
        }
        
        super.draw(rect)
    }

}
