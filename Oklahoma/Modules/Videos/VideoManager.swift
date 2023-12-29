//
//  VideoManager.swift
//  Oklahoma
//
//  Created by Chakshu Dawara on 27/12/23.
//

import Foundation
import RealmSwift
import Realm

struct VideoManager {
        static let realm = try! Realm()
        typealias CompletionH = (Bool, Error?) -> ()

    // get all videos chapter
    static func getAllChapters() -> [Video] {
        Video.setupVideoData()
        let videos = realm.objects(Video.self)
        print("the chapters count is ", videos.count)
        return Array(videos)
    }
    
    // get all videos chapter
    static func getAllInitialVideoChapters() -> [Video] {
        let videos = realm.objects(Video.self)
        
        for video in videos {
            if !video.isDownloaded {
                video.updateDownloadPath(value: "")
            }
        }
        return Array(videos)
    }
    
    // get videos chapters for the similar id in playerViewController
    static func getChaptersOfId(chapterID: String) -> [Video] {
               
        let predicate = NSPredicate(format: "identifer BEGINSWITH %@",(chapterID))
        let chapters = realm.objects(Video.self).filter(predicate)
        return Array(chapters)
    }
    
    static func removeDownloadedVideo(_ completion: CompletionH, chapterNumber: String) {
        let realm = try! Realm()
        guard let selectedVideo = realm.objects(Video.self).filter("chapterNumber == %@", chapterNumber).first else { return }
        
        guard let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let pathComponent = chapterNumber + Constants.Video.fileExtension
        let path = "/\(documentsURL.path)/\(pathComponent)"
        if !path.isEmpty {
            do {
                try FileManager.default.removeItem(atPath: path)
                do {
                    try realm.write {
                        selectedVideo.isDownloaded = false
                        selectedVideo.downloadPath = ""
                    }
                    completion(true, nil)
                } catch {
                    completion(false, error)
                }
            } catch {
                completion(false, error)
            }
        }
    }
    
    
    static func removeAllDownloadedVideos(_ completion: CompletionH) {
        let realm = try! Realm()
        let videos = realm.objects(Video.self)
        guard let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        
        for video in videos {
            if video.isDownloaded {
                let pathComponent = video.chapterNumber + Constants.Video.fileExtension
                let path = "/\(documentsURL.path)/\(pathComponent)"
                if !path.isEmpty {
                    do {
                        print("PATH:", path)
                        try FileManager.default.removeItem(atPath: path)
                        try realm.write {
                            video.isDownloaded = false
                            video.downloadPath = ""
                        }
                        completion(true, nil)
                    } catch {
                        completion(false, error)
                    }
                }
            }
        }
        
    }
}
