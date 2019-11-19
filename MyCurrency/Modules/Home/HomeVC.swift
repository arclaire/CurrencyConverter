//
//  HomeVC.swift
//  MyCurrency
//
//  Created by Lucy on 18/11/19.
//  Copyright © 2019 arclaire. All rights reserved.
//

import UIKit

class HomeVC: BaseViewController {
	
	@IBOutlet weak var viewHeader: UIView!
	@IBOutlet weak var textfieldInput: UITextField!
	@IBOutlet weak var labelResult: UILabel!
	
	@IBOutlet weak var buttonConvert: UIButton!
	@IBOutlet weak var buttonCurrency: UIButton!
	@IBOutlet weak var buttonCurrency2: UIButton!
	@IBOutlet weak var flowlayout: UICollectionViewFlowLayout!
	
	@IBOutlet weak var collectionview: UICollectionView!
	var viewModel = HomeViewModel()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.collectionview.dataSource = self
		self.collectionview.delegate = self
		let nib = UINib(nibName: String(describing: CellResultConvert.self), bundle: nil)
		self.collectionview.register(nib, forCellWithReuseIdentifier: String(describing: CellResultConvert.self))
		self.bindViewModel()
		let tapgesture = UITapGestureRecognizer(target: self, action: #selector(dismisKeyboard))
		self.view.addGestureRecognizer(tapgesture)
		self.buttonCurrency.isEnabled = false
	}
	
	@objc func dismisKeyboard() {
		self.view.endEditing(true)
	}
	
	func bindViewModel() {
		self.viewModel.dataSourceObservable
			.asObservable()
			.subscribe(onNext: { [unowned self] _ in
				self.setviewData()
				
			})
			.disposed(by: disposeBag)
		
		self.viewModel.state.asObservable()
			.subscribe(onNext: { [unowned self] (loadingState) in
				self.setviewData()
			})
			.disposed(by: disposeBag)
		
		self.viewModel.getCurrencyList()
		self.viewModel.getRateList()
	}
	
	func setviewData() {
		self.collectionview.reloadData()
		self.buttonCurrency.setTitle(self.viewModel.strCurrencyCurrent, for: .normal)
	}
	
	func showPicker(btn: UIButton) {
		RPicker.selectOption(dataArray: self.viewModel.arrCurrencyList,
							 didSelectValue: {(strName, index) in
								btn.setTitle(strName, for: .normal)
								
								
		})
	}
	
	func calculateConvertedCurrncy() {
		self.view.endEditing(true)
		if let str = self.textfieldInput.text {
			var rate: Double = 1.0
			if let convertTo = self.buttonCurrency2.titleLabel?.text {
				rate = self.getRateOfCurrency(str: convertTo) ?? 1.0
			}
			
			let doubleInput: Double = Double(str) as! Double
			let result = doubleInput * rate
			self.labelResult.text = String(result)
		}
		
	}
	
	func getRateOfCurrency(str: String) -> Double? {
		let code = self.viewModel.strCurrencyCurrent + str
		for data in self.viewModel.modelCell {
			if code == data.strCurrencyName {
				return data.doubleValue
			}
			
		}
		return 0.0
	}
	
	@IBAction func actionButton(_ sender: Any) {
		if let button = sender as? UIButton {
			if button == self.buttonConvert{
			
				self.calculateConvertedCurrncy()
			}
			
			if button == self.buttonCurrency {
				self.showPicker(btn: button)
			}
			
			if button == self.buttonCurrency2 {
				self.showPicker(btn: button)
			}
		}
	}
}


extension HomeVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		var count = 0
		if let _ = self.viewModel.modelRate?.quotes{
			count = self.viewModel.modelCell.count
		}
		
		return count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: CellResultConvert.self), for: indexPath) as! CellResultConvert
		let value = self.viewModel.modelCell[indexPath.row].doubleValue
		let str = self.viewModel.arrCurrencyList[indexPath.row]
		cell.labelName.text = self.viewModel.strCurrencyCurrent + " -> " + str
		cell.labelRate.text = String(format:"%f", value ?? 0.0)
		return cell
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		let size = CGSize(width: (UIScreen.main.bounds.size.width - 35) / 3 , height: 100)
		return size
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		//let currentCell = collectionView.cellForItem(at: indexPath) as! ProductCell
		
	}
	
	
}
