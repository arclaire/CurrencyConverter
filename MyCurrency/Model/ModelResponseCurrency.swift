//
//  ModelResponseCurrency.swift
//  MyCurrency
//
//  Created by Lucy on 18/11/19.
//  Copyright © 2019 arclaire. All rights reserved.
//

import Foundation

struct ModelCurrency: Codable {
	let success: Bool?
    let terms: String?
	let privacy: String?
	let currencies: [String:String]?
    
}

struct ModelRate: Codable {
	let success: Bool?
    let terms: String?
	let privacy: String?
	let source: String?
	let quotes: [String:Double]?
	
}
