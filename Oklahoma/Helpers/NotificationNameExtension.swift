//
//  NotificationNameExtension.swift
//  Oklahoma
//
//  Created by Chakshu Dawara on 27/12/23.
//

import Foundation

extension Notification.Name {
    static let playerCurrentTime = Notification.Name("playerSeekTime")
    static let playerStatus = Notification.Name("playerIsRunning")
    static let playerInstance = Notification.Name("playerInstance")
    static let audiobookPurchase = Notification.Name("audiobookPurchase")
    static let examPrepPurchase = Notification.Name("examPrepPurchase")
    static let coursePurchase = Notification.Name("coursePurchase")
    static let videoDownloadPurchase = Notification.Name("videoDownloadPurchase")
    static let pauseAudio = Notification.Name("pauseAudio")
    static let stopAudio = Notification.Name("stopAudio")
    static let isConnectToNetwork = Notification.Name("connected")
    static let isNotConnectedToNetwork = Notification.Name("notConnected")
    static let hideTabBar = Notification.Name("hideTabBar")
    static let saveTimeOnAppClose = Notification.Name("saveTimeOnAppClose")
    static let playLastPlayedAudio = Notification.Name("playLastPlayedAudio")
    static let playLastVideo = Notification.Name("playLastVideo")
    static let moveToHome = Notification.Name("moveToHome")
    static let loaderProgress = Notification.Name("loaderProgress")
    static let loaderProgressCompleted = Notification.Name("loaderProgressCompleted")
    static let downloadVideo = Notification.Name("downloadVideo")
    static let setCourseScreenOrientation = Notification.Name("setCourseScreenOrientation")
    static let languageChanged = Notification.Name("languageChanged")
}
