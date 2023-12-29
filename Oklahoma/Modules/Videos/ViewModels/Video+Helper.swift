//
//  Video+Helper.swift
//  Oklahoma
//
//  Created by Chakshu Dawara on 27/12/23.
//

import Foundation

extension Video {
    
    var thumbnail: String {
        return "skill_" + self.identifer.replacingOccurrences(of: "-", with: "_")
    }
    
    var chapterIdentifier: String {
        return "\(Text.skill.localize()) " + self.identifer
    }
    
}
