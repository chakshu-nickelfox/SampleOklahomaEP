//
//  IAPProductModel.swift
//  Oklahoma
//
//  Created by Chakshu Dawara on 26/12/23.
//

import Foundation
import StoreKit

class IAPProductModel {
    
    var products = [SKProduct]()
        
    func getProduct(containing keyword: String) -> SKProduct? {
        return products.filter { $0.productIdentifier.contains(keyword) }.first
    }
}
