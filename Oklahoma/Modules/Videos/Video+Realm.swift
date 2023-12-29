//
//  Video+Realm.swift
//  Oklahoma
//
//  Created by Chakshu Dawara on 27/12/23.
//

import Foundation
import Realm
import RealmSwift
import Alamofire

public class Video: Object {
    
    @objc dynamic public var identifer = ""
    @objc dynamic public var chapterTitle = ""
    @objc dynamic public var videoId = ""
    @objc dynamic public var videoDuration = ""
    @objc dynamic public var isBookmarked = false
    @objc dynamic public var chapterNumber = ""
    @objc dynamic public var steps: String = ""
    @objc dynamic public var notes: String = ""
    @objc dynamic public var webLink = ""
    @objc dynamic public var downloadLink = ""
    @objc dynamic public var isDownloaded = false
    @objc dynamic public var parentVideo = false
    @objc dynamic public var downloadPath = ""
    @objc dynamic public var lastProgressTime: TimeInterval = 0
    @objc dynamic public var isDownloading = false
    @objc dynamic public var downloadStatus = 0
    
    
    public let subVideos = List<Video>()
    
    @objc let separator = "￿"
    
    @objc dynamic public var stepsList: [String] {
        // get { return steps.components(separatedBy: separator) ?? [] }
        get { return steps.components(separatedBy: separator) }
        set { steps = newValue.isEmpty ? "" : newValue.joined(separator: separator)}
    }
    
    @objc dynamic public var notesList: [String]
    {
        // get { return notes.components(separatedBy: separator) ?? [] }
        get { return notes.components(separatedBy: separator) }
        set { notes = newValue.isEmpty ? "" : newValue.joined(separator: separator)}
    }
    
    public override class func ignoredProperties() -> [String] {
        return ["stepsList", "notesList"]
    }
    
    public override static func primaryKey() -> String? {
        return "videoId"
    }
    
    public var downloadTask: URLSessionDownloadTask?
    public var observation: NSKeyValueObservation?
    
}

extension Video {
    
    public static func setupVideoData() {
        
        guard !DataModel.shared.isVideosLoaded,
              let url = Bundle.main.url(forResource: "Videos", withExtension: "json"),
              let data = try? Data(contentsOf: url) else { return }
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: [])
            
            do {
                let realm = try Realm()
                if let videos = json as? [[String: Any]] {
                    
                    for video in videos {
                        do {
                            try realm.write {
                                realm.create(Video.self, value: video, update: .all)
                            }
                        } catch {
                            print(error)
                        }
                    }
                }
                DataModel.shared.isVideosLoaded = true
            } catch {
                print(error.localizedDescription)
            }
        } catch {
            print(error.localizedDescription)
        }
      }
    
    public func updateBookmark() {
        do {
            let realm = try Realm()
            do {
                try realm.write {
                    self.isBookmarked = !self.isBookmarked
                }
            } catch {
                print(error)
            }
        } catch {
            print(error)
        }
    }
    
    public func updateDownload(value: Int) {
        do {
            let realm = try Realm()
            do {
                try realm.write {
                    self.isDownloading = value == 1
                    self.isDownloaded = value == 2
                    /// downloadStatus contains interger value to indicate different status of downloading more details on value can be found in DownloadState enum, will remove isDownloading & isDownloaded in future migration
                    self.downloadStatus = value
                }
            } catch {
                print(error)
            }
        } catch {
            print(error)
        }
    }
    
    public func updateDownloadPath(value: String) {
        do {
            let realm = try Realm()
            do {
                try realm.write {
                    self.downloadPath = value
                }
            } catch {
                print(error)
            }
        } catch {
            print(error)
        }
    }
    
    public func updateProgressTime(lastProgressTime: Double) {
        do {
            let realm = try Realm()
            do {
                try realm.write {
                    self.lastProgressTime = lastProgressTime
                }
            } catch {
                print(error)
            }
        } catch {
            print(error)
        }
    }
    
}

extension Video {
    
    var thumbnail: String {
        return "skill_" + self.identifer.replacingOccurrences(of: "-", with: "_")
    }
    
    var chapterIdentifier: String {
        return "\("skill") " + self.identifer
    }
    
}

public typealias FileProgress = Alamofire.Progress

public extension Video {
    
    
    func cancelDownloadVideo(pathComponent: String) {
        self.downloadTask?.cancel()
    }
    
    func downloadVideo(pathComponent: String,
                                   videoUrl: URL,
                                   downloadProgressed: @escaping (FileProgress) -> Void, completion: @escaping (Bool) -> Void) {
        
        self.downloadTask = URLSession.shared.downloadTask(with: videoUrl, completionHandler: { localUrl, response, error in
            if let error = error {
                print("Error while downlaoding video: ", error)
                
                DispatchQueue.main.async {
                    self.updateDownload(value: DownloadState.notDownloaded.rawValue)
                    self.updateDownloadPath(value: "")
                    completion(false)
                }
                
//                self.downloadTask = nil
                return
            }
            
            if let localUrl = localUrl {
                print("Successfully downlaoded video to:  ", localUrl.absoluteString)
                
                guard let data = try? Data(contentsOf: localUrl) else {
                    completion(false)
                    return
                }
                
                let destinationPath = self.createFileURL(pathComponent: pathComponent)
                
                try? data.write(to: destinationPath, options: .atomic)
                
                try? FileManager.default.removeItem(at: localUrl)
                DispatchQueue.main.async {
                    self.updateDownload(value: DownloadState.downloadComplete.rawValue)
                    completion(true)
                }
                
            }
        })
        
        self.observation = downloadTask?.progress.observe(\.fractionCompleted, changeHandler: { progress, _ in
            print("Downlaoding using URLSession: ", progress.fractionCompleted)
            DispatchQueue.main.async {
                downloadProgressed(progress)
            }
            
        })
        self.downloadTask?.resume()
        
    }
    
    func createFileURL(pathComponent: String) -> URL {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsURL.appendingPathComponent(pathComponent)    // like "image.png"
        return fileURL
    }
}
