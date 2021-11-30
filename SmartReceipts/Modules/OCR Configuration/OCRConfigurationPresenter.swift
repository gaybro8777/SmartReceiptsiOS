//
//  OCRConfigurationPresenter.swift
//  SmartReceipts
//
//  Created by Bogdan Evsenev on 25/10/2017.
//Copyright © 2017 Will Baumann. All rights reserved.
//

import Foundation
import Viperit
import RxSwift
import StoreKit

class OCRConfigurationPresenter: Presenter {
    private let bag = DisposeBag()
    
    override func viewHasLoaded() {
        interactor.requestProducts()
            .subscribe(onNext: { [weak self] product in
                guard let sSelf = self else { return }
                let price = Observable<String>.just(product.localizedPrice)
                switch product.productIdentifier {
                case PRODUCT_STANDARD_SUB: _ = price.bind(to: sSelf.view.OCR10Price)
                case PRODUCT_PREMIUM_SUB: _ = price.bind(to: sSelf.view.OCR50Price)
                default: break
                }
            }).disposed(by: bag)
        
        Observable<String>
            .merge([view.buy10ocr.map { PRODUCT_STANDARD_SUB }, view.buy50ocr.map { PRODUCT_PREMIUM_SUB  }])
            .subscribe(onNext: { [weak self] in
                self?.buy(productId: $0)
            }).disposed(by: bag)
            
        view.logoutTap
            .bind(to: interactor.logout)
            .disposed(by: bag)
    }
    
    private func buy(productId: String) {
        self.interactor.purchase(product: productId)
            .delay(1, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.view.updateScansCount()
            }).disposed(by: bag)
    }
    
    var errorHandler: AnyObserver<String> {
        return view.errorHandler
    }
    
    var successLogout: AnyObserver<Void> {
        return view.successLogoutHandler
    }
}


// MARK: - VIPER COMPONENTS API (Auto-generated code)
private extension OCRConfigurationPresenter {
    var view: OCRConfigurationViewInterface {
        return _view as! OCRConfigurationViewInterface
    }
    var interactor: OCRConfigurationInteractor {
        return _interactor as! OCRConfigurationInteractor
    }
    var router: OCRConfigurationRouter {
        return _router as! OCRConfigurationRouter
    }
}
