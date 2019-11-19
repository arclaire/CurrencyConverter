//
//  HomeViewModel.swift
//  MyCurrency
//
//  Created by danang sakti on 18/11/19.
//  Copyright © 2019 arclaire. All rights reserved.
//

import Foundation

struct ModelHomeVC {
	var modelCurrency: ModelCurrency?
	var modelRate: ModelRate?
}

struct ModelCellRate {
	var strCurrencyName: String?
	var doubleValue: Double?
}

class HomeViewModel: BaseViewModel {
	var strCurrencyCurrent: String = "USD"
	var modelCurrency: ModelCurrency?
	var modelRate: ModelRate? {
		didSet{
			self.generateData()
		}
	}
	var modelCell: [ModelCellRate] =  [ModelCellRate]()
	var dataSourceObservable = BehaviorRelay<ModelHomeVC?>(value:nil)
	var dataSource: ModelHomeVC? {
		get {
			return dataSourceObservable.value
		}
		set {
			dataSourceObservable.accept(newValue)
		}
	}
	
	var arrCurrencyList: [String] = [String]()
	
	func generateData() {
		guard let data = self.modelRate?.quotes else {return}
		self.modelCell.removeAll()
		for (key, value) in data {
			let index = key.index(key.startIndex, offsetBy: 3)
			self.strCurrencyCurrent = String(key.prefix(upTo: index))
			self.modelCell.append(ModelCellRate(strCurrencyName: key, doubleValue: value))
			let str = key.uppercased().replacingOccurrences(of: self.strCurrencyCurrent, with: "")
			if !str.isEmpty {
			  self.arrCurrencyList.append(str)
			}
		}
	}
	
	func getCurrencyList() {
		return NetworkCurrencyLayer()
			.fetchListCurrency()
			.catchError({ [unowned self] error -> Observable<ModelCurrency?> in
				self.handleNetworkError(error)
				return Observable.just(nil)
			})
			.subscribe(onNext: { [unowned self] modelResponse in
				if let validModel = modelResponse {
					self.dataSource?.modelCurrency = validModel
					self.state.accept(.finished)
					
				} else {
					
					self.state.accept(.failed)
				}
			}).disposed(by: disposeBag)
	}
	
	func getRateList() {
		return NetworkCurrencyLayer()
			.fetchLiveRate(arrCurrencies: nil)
			.catchError({ [unowned self] error -> Observable<ModelRate?> in
				self.handleNetworkError(error)
				return Observable.just(nil)
			})
			.subscribe(onNext: { [unowned self] modelResponse in
				if let validModel = modelResponse {
					self.dataSource?.modelRate = validModel
					self.modelRate = validModel
					self.state.accept(.finished)
					
				} else {
					
					self.state.accept(.failed)
				}
			}).disposed(by: disposeBag)
	}
	
	
}
