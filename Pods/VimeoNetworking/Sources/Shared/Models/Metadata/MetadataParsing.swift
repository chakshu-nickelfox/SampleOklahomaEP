//
//  MetadataParsing.swift
//  VimeoNetworking
//
//  Created by Balatbat, Bryant on 7/30/18.
//  Copyright © 2019 Vimeo. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation

typealias Metadata = [AnyHashable: Any]

protocol MetadataParsing {
    
    /// Given `Metadata`, parses it into a dictionary of `MetadataKeys` to a `VIMModelObject`
    ///
    /// - Parameters:
    ///   - metadata: `Metadata` to be parsed
    ///   - type: The `Metadata` type
    ///   - mapping: Mapping used to map `Metadatakeys` to a `VIMModelObject`
    /// - Returns: `Dictionary` that maps `Metadatakeys` to a `VIMModelObject`
    func parse<Keys: MetadataKeys, ModelType: VIMModelObject>(_ metadata: Metadata, type: MetadataType, mapping: [Keys: ModelType.Type]) -> [Keys: ModelType] where Keys.RawValue == String
}

extension MetadataParsing {
    func parse<Keys: MetadataKeys, ModelType: VIMModelObject>(_ metadata: Metadata, type: MetadataType, mapping: [Keys: ModelType.Type] = [:]) -> [Keys: ModelType] where Keys.RawValue == String {
        
        guard let childMetadata = metadata[type.rawValue] as? [String: [AnyHashable: Any]] else {
            return [:]
        }
        
        return childMetadata.reduce([Keys: ModelType]()) { (partialResult, nextKeyValueTuple) -> [Keys: ModelType] in
            
            var partialResult = partialResult
            
            guard let key = Keys.init(rawValue: nextKeyValueTuple.key) else {
                return partialResult
            }
            
            let type = mapping[key] ?? ModelType.self
            
            if let model = type.init(keyValueDictionary: nextKeyValueTuple.value) {
                partialResult[key] = model
            }
            
            return partialResult
        }
    }
}

enum MetadataType: String {
    case connections
    case interactions
}
