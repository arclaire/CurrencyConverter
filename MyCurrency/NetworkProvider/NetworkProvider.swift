//
//  NetworkProvider.swift
//  MyCurrency
//
//  Created by danang sakti on 18/11/19.
//  Copyright © 2019 arclaire. All rights reserved.
//


import Foundation
import Alamofire
import RxSwift

struct Connectivity {
    static let sharedInstance = NetworkReachabilityManager()!
    static var isConnectedToInternet:Bool {
        return self.sharedInstance.isReachable
    }
}

class NetworkProvider {
    
    func get(_ urlString: String, params: [String: Any]? = [:], bodyParams: [String: Any]? = nil) -> Observable<Any?> {
        return requestWithMethod(.get, urlString: urlString, params: params, bodyParams: bodyParams)
    }
    
    func post(_ urlString: String, params: [String: Any]? = [:], bodyParams: [String: Any]? = nil) -> Observable<Any?> {
        return requestWithMethod(.post, urlString: urlString, params: params, bodyParams: bodyParams)
    }
    
    func put(_ urlString: String, params: [String: Any]? = [:], bodyParams: [String: Any]? = nil) -> Observable<Any?> {
        return requestWithMethod(.put, urlString: urlString, params: params, bodyParams: bodyParams)
    }
    
    func delete(_ urlString: String, params: [String: Any]? = [:], bodyParams: [String: Any]? = nil) -> Observable<Any?> {
        return requestWithMethod(.delete, urlString: urlString, params: params, bodyParams: bodyParams)
    }
    
    func requestWithMethod(_ method: HTTPMethod, urlString: String, params: [String: Any]?, bodyParams: [String: Any]? = nil) -> Observable<Any?> {
        return Observable<Any?>.create({ (observer) -> Disposable in
            if Connectivity.isConnectedToInternet == false {
                observer.onError(NSError(domain: "", code: NSURLErrorNotConnectedToInternet, userInfo: nil))
            } else {
                var urlEncodedRequest: URLRequest?
                do {
                    var urlRequest = URLRequest(url: URL(string: urlString)!)
                    urlRequest.httpMethod = method.rawValue
                    urlEncodedRequest = try URLEncoding.default.encode(urlRequest, with: params)
                    SQLogger.log("HEADER: \(String(describing: urlRequest.allHTTPHeaderFields))", logType: .kNetworkRequest)
                    SQLogger.log("URL: \(urlString)", logType: .kNetworkRequest)
                    
                } catch let error {
                    SQLogger.log(error, logType: .kNetworkRequest)
                }
                
                if let urlRequest = urlEncodedRequest {
                    let request = Alamofire.request(urlRequest).validate()
                    request.responseJSON(completionHandler: { response in
                        switch response.result {
                        case .success(let response):
                            SQLogger.log(response, logType: .kNetworkResponseSuccess)
                            observer.onNext(response)
                            observer.onCompleted()
                        case .failure(let error as NSError):
                            SQLogger.log(error, logType: .kNetworkResponseError)
                            let requestError = NSError(domain: error.domain, code: response.response?.statusCode ?? error.code, userInfo: error.userInfo)
                            if let validErrorData = response.data, validErrorData.count > 0 {
                                do {
                                    let mainError = try JSONDecoder().decode(ModelArrayErrors.self, from: validErrorData)
                                    if var errorFirst = mainError.errors?.first {
                                        errorFirst.status = NSNumber(value: response.response?.statusCode ?? error.code)
                                        observer.onError(errorFirst)
                                    } else {
                                        observer.onError(response.result.error ?? requestError)
                                    }
                                } catch {
                                    observer.onError(response.result.error ?? requestError)
                                }
                            } else {
                                observer.onError(response.result.error ?? error)
                            }
                        default: break
                        }
                    })
                    return Disposables.create (with: {
                        request.cancel()
                    })
                }
            }
            return Disposables.create()
        }).retryWhen { (error: Observable<Error>) -> Observable<Bool> in
            return error.flatMap({ error -> Observable<Bool> in
                
                return Observable.error(error)
            })
        }
    }
}
