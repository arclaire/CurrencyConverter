//
//  BaseViewController.swift
//  MyCurrency
//
//  Created by danang sakti on 19/11/19.
//  Copyright © 2019 arclaire. All rights reserved.
//

import UIKit


import NVActivityIndicatorView

class BaseViewController: UIViewController {
	var disposeBag = DisposeBag()
	let activityIndicatorView = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 40.0, height: 40.0))
	
	lazy var refreshControl: UIRefreshControl = {
		let refreshControl = UIRefreshControl()
		return refreshControl
	}()
	
	override func loadView() {
		super.loadView()
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		view.addSubview(activityIndicatorView)
		activityIndicatorView.type = .circleStrokeSpin
		activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
		view.placeAtTheCenterWithView(view: activityIndicatorView)
		
		loadLocalizableTexts()
		setupReachability()
	}
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		if #available(iOS 12.0, *) {
			if traitCollection.userInterfaceStyle == .light {
				if #available(iOS 13.0, *) {
					return .darkContent
				} else {
					return .default
				}
			} else {
				return .lightContent
			}
		} else {
			return .default
		}
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		navigationController?.setNavigationBarHidden(true, animated: true)
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
		NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
		NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
	
	func setupReachability() {
		do {
			let reachability = try Reachability()
			NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(note:)), name: .reachabilityChanged, object: reachability)
			do {
				try reachability.startNotifier()
			} catch {
				SQLogger.log("could not start reachability notifier")
			}
		} catch {
			SQLogger.log("could not start reachability")
		}
	}
	
	@objc func reachabilityChanged(note: Notification) {
		if let reachability = note.object as? Reachability {
			networkReachabilityStatus(reachability.connection)
		}
	}
	
	func networkReachabilityStatus(_ status: Reachability.Connection) {
		
	}
	
	func handleRefreshContent() {
		
	}
	
	func loadLocalizableTexts() {
		
	}
	
	func confirmSendBirdDelegate() {
		
	}
	
	func keyboardHeight() -> Observable<CGFloat> {
		return Observable
			.from([
				NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification)
					.map { notification -> CGFloat in
						(notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height ?? 0
				},
				NotificationCenter.default.rx.notification(UIResponder.keyboardWillHideNotification)
					.map { _ -> CGFloat in
						0
				}
			])
			.merge()
	}
	
	func setupRefreshControl(_ scrollView: UITableView) {
		refreshControl.addTarget(self, action: #selector(BaseViewController.triggerRefreshControl), for: .valueChanged)
		scrollView.addSubview(refreshControl)
	}
	
	@objc func triggerRefreshControl() {
		refreshControl.endRefreshing()
		handleRefreshContent()
	}
	
	func toggleIndicatorLoadingMode(_ loading: Bool) {
		DispatchQueue.main.async {
			loading ? self.activityIndicatorView.startAnimating() : self.activityIndicatorView.stopAnimating()
		}
	}
	
	deinit {
		SQLogger.log("Deinit \(type(of: self))")
	}
	
	
	func bindErrorStateInViewModel(_ viewModel: BaseViewModel) {
		viewModel.errorModelObservable
			.asObservable()
			.subscribe(onNext: { [unowned self] errorModel in
				self.showError(errorModel)
			}).disposed(by: disposeBag)
	}
	
	
	func showError(_ errorModel: ModelError?) {
		if let validErrorModel = errorModel {
			if let statusCode = validErrorModel.status, statusCode.intValue == NSURLErrorNotConnectedToInternet { //Show login for Unauthorized access
				print("Internet connection not available.")
			} else {
				
			}
		}
	}
	
	func showAlertWithTitleAndMessage(title: String? = "Alert", message: String, handler: ((UIAlertAction) -> Swift.Void)? = nil) {
		DispatchQueue.main.async {
			let alert = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: handler))
			self.present(alert, animated: true, completion: {
			})
		}
	}
	
	@objc func customBackButtonTapped() {
		navigationController?.popViewController(animated: true)
	}
}


extension BaseViewController {
	func applyNavigationBarStyle() {
		navigationController?.navigationBar.titleTextAttributes = [
			NSAttributedString.Key.foregroundColor: UIColor.white,
		]
		
		navigationItem.backBarButtonItem = UIBarButtonItem(image: nil, style: .plain, target: nil, action: nil)
	}
	
	func updateTitle(_ rawTitle: String) {
		title = rawTitle.uppercased()
	}
	
	
	func hideNavigationBackButton() {
		navigationItem.hidesBackButton = true
	}
	
	func popToVC(vc:AnyClass) {
		if let arrVC = self.navigationController?.viewControllers {
			if arrVC.count > 0 {
				for v in arrVC.reversed() {
					if v.isKind(of: vc) {
						self.navigationController?.popToViewController(v, animated: true)
						break
					}
				}
				self.navigationController?.popViewController(animated: true)
			} else {
				self.navigationController?.popViewController(animated: true)
			}
		} else {
			self.navigationController?.popViewController(animated: true)
		}
		
	}
	
}


extension UIView {
	func placeAtTheCenterWithView(view: UIView) {
		addConstraint(NSLayoutConstraint(item: view, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0))
		addConstraint(NSLayoutConstraint(item: view, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0))
	}
}
