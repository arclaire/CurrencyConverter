//
//  NetworkConfigurations.swift
//  MyCurrency
//
//  Created by danang sakti on 18/11/19.
//  Copyright © 2019 arclaire. All rights reserved.
//

import Foundation


struct NetworkConfigurations {
    
    fileprivate static let DevBaseUrl = "https://currencylayer.com/"
	fileprivate static let ProdBaseUrl = "https://currencylayer.com/"
    
    fileprivate static let kClientSecret = ""
    
    static let kTokenExpiredErrorCode = 405
    static let kGatewayTimeoutErrorCode = 503
    static let kMissingPhoneNumberErrorCode = 403
    
    //properBaseUrl will be lazy load and called only once on first access
    static var properBaseUrl: String = {
        #if DEBUG
        return DevBaseUrl
        #else
        return ProdBaseUrl
        #endif
    }()
    
    static func parseCurrentUrlHost() -> String {
        let currentBaseUrl = URL(string: properBaseUrl)!
        return currentBaseUrl.host!
    }
    
}
