//
//  NetworkCurrencyLayer.swift
//  MyCurrency
//
//  Created by danang sakti on 18/11/19.
//  Copyright © 2019 arclaire. All rights reserved.
//

import Foundation
import RxSwift

// access key a0e8c438dd43cc62e7d43420e0dc1766

class NetworkCurrencyLayer {
	func fetchListCurrency() -> Observable<ModelCurrency?> {
       
		let url = "https://apilayer.net/api/list?access_key=a0e8c438dd43cc62e7d43420e0dc1766"
       
        return NetworkProvider().get(url).map { response in
            
            if let data = response as? [AnyHashable: Any] {
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
                    let decode = try JSONDecoder().decode(ModelCurrency.self, from: jsonData)
                    return decode
                } catch let error {
                    print(error)
                }
            }
            
            return nil
        }
    }
	func fetchLiveRate(arrCurrencies: [String]?) -> Observable<ModelRate?> {
       
		let url = "http://www.apilayer.net/api/live?access_key=a0e8c438dd43cc62e7d43420e0dc1766"
		
        return NetworkProvider().get(url).map { response in
            
            if let data = response as? [AnyHashable: Any] {
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
                    let decode = try JSONDecoder().decode(ModelRate.self, from: jsonData)
                    return decode
                } catch let error {
                    print(error)
                }
            }
            
            return nil
        }
        
    }
	
	
}
