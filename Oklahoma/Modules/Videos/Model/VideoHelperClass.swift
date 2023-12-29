//
//  VideoHelperClass.swift
//  Oklahoma
//
//  Created by Chakshu Dawara on 27/12/23.
//

import RealmSwift
import SystemConfiguration
import VimeoNetworking
import ReactiveSwift

class VideoHelperClass: NSObject {
    typealias completionH = (Bool, Error?) -> ()
    private let initializedVideos = "initVideos"
    @objc var videoSheetInput = [VideoFileFormat]()

    static func removeDownloadedVideo(_ completion: completionH, chapterNumber: String) {
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

}
