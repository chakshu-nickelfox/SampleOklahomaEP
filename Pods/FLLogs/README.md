# FLLogs
FLLogs is a logging utility for Swift that provides a simple and convenient way to log messages during the development and debugging phases of an iOS or macOS app. It allows developers to log messages with different log levels and customize the format and destination of the logs.

## Installation
#### <i class="icon-file"></i>**CocoaPods**
[CocoaPods](https://cocoapods.org) is the dependency manager for Cocoa Libraries. You can install Cocoapods using the following command:

> `$ sudo gem install cocoapods`

If you wish to integrate `FLLogs` in your project, then make following changes in your `Podfile`:

```  
platform :ios, '10.0'
use_frameworks!
target 'YourAppName' do
pod "FLLogs"
end
```

After saving `Podfile`. Run the following command:

> `$ pod install`


#### <i class="icon-pencil"></I>**Install using Swift Package Manager**

The [Swift Package Manager](https://swift.org/package-manager) is a tool for automating the distribution of Swift code and is integrated into the swift compiler.

Once you have your Swift package set up, adding FLLogs as a dependency is as easy as adding it to the ```dependencies``` value of your ```Package.swift```.

```
dependencies: [
    .package(url: "https://github.com/Nickelfox/FLLogs", .branch("master"))
]
```
#### <i class="icon-pencil"></I>**Manually**
If you don't want to use any dependency manager in your project, you can install this library manually too.
Just download and add the `Source` folder to your project.

## Features

- Log messages with different log levels: .debug, .info, .warning, .error, and .custom.
- Customize log format with date, log level, tag, and message.
- Print logs to console or write logs to a file.
- Filter logs by log level and/or tags.
- Enable or disable logs globally or selectively.
- Support for asynchronous logging to minimize performance impact.

## Usage

1. Import FLLogs in your Swift file:
```ruby
import FLLogs
```


2. Create a `Logging` class and use different helper function for type of logs as `.verbose`, `.debug`, `.info`, `.warning`, `.severe`
```ruby
import Foundation
import FLLogs

public func logVerbose(_ closure: @autoclosure @escaping () -> Any?, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line, userInfo: [String: Any] = [:]) {
    
    verboselog(closure(), functionName: functionName,
               fileName: fileName, lineNumber: lineNumber,
               userInfo: userInfo)
}

public func logDebug(_ closure: @autoclosure @escaping () -> Any?, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line, userInfo: [String: Any] = [:]) {
    debuglog(closure(), functionName: functionName,
               fileName: fileName, lineNumber: lineNumber,
               userInfo: userInfo)
}

public func logInfo(_ closure: @autoclosure @escaping () -> Any?, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line, userInfo: [String: Any] = [:]) {
    infolog(closure(), functionName: functionName,
               fileName: fileName, lineNumber: lineNumber,
               userInfo: userInfo)
}

public func logWarning(_ closure: @autoclosure @escaping () -> Any?, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line, userInfo: [String: Any] = [:]) {
    warninglog(closure(), functionName: functionName,
               fileName: fileName, lineNumber: lineNumber,
               userInfo: userInfo)
}

public func logError(_ closure: @autoclosure @escaping () -> Any?, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line, userInfo: [String: Any] = [:]) {
    errorlog(closure(), functionName: functionName,
               fileName: fileName, lineNumber: lineNumber,
               userInfo: userInfo)
}

public func logSevere(_ closure: @autoclosure @escaping () -> Any?, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line, userInfo: [String: Any] = [:]) {
    severelog(closure(), functionName: functionName,
               fileName: fileName, lineNumber: lineNumber,
               userInfo: userInfo)
}
```
