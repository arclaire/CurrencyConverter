//
//  ModelError.swift
//  MyCurrency
//
//  Created by Lucy on 18/11/19.
//  Copyright © 2019 arclaire. All rights reserved.
//

import Foundation

struct ModelArrayErrors: Codable, Error {
    var errors: [ModelError]?
    
    enum CodingKeys: String, CodingKey {
        case errors = "errors"
    }
}

struct ModelError: Codable, Error {
    var title: String?
    var detail: String?
    var errorImageUrl: String?
    var status: NSNumber?

    enum CodingKeys: String, CodingKey {
        case title
        case detail
    }
}


extension ModelError {
    init(systemError: NSError) {
        self.init()
        self.status = systemError.code as NSNumber

        if systemError.code == NSURLErrorNotConnectedToInternet ||
            systemError.code == NSURLErrorNetworkConnectionLost  ||
            systemError.code == NetworkConfigurations.kGatewayTimeoutErrorCode {
            
            self.title = "title"
            self.detail = "no connection"
        } else {
            self.title = systemError.localizedDescription
            self.detail = systemError.localizedRecoverySuggestion
        }
    }
}
