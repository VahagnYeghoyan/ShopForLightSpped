//
//  ProductModel.swift
//  ShopLightspeed
//
//  Created by Vahagn Yeghoyan on 10/30/24.
//

import Foundation

class ProductModel: Codable {
    
    let id: Int
    let title: String
    let price: Double
    let description: String
    let images: [String]
    let rating: Double
    let category: String
}

class ProductContainer: Codable {
    
    let products: [ProductModel]
}

