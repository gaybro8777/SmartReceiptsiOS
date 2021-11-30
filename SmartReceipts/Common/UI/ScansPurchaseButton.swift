//
//  ScansPurchaseButton.swift
//  SmartReceipts
//
//  Created by Bogdan Evsenev on 27/10/2017.
//  Copyright © 2017 Will Baumann. All rights reserved.
//

import UIKit
import RxSwift

class ScansPurchaseButton: UIButton {
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subtitle: UILabel!
    @IBOutlet fileprivate weak var price: UILabel!
    @IBOutlet fileprivate weak var priceSubtitle: UILabel!
    @IBOutlet fileprivate weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet fileprivate weak var priceBackground: UIView!
 
    private let bag = DisposeBag()
    
    override func awakeFromNib() {
        layer.cornerRadius = 7
        
        rx.controlEvent(.touchDown)
            .subscribe(onNext: { [unowned self] in
                self.backgroundColor  = UIColor.srViolet2.withAlphaComponent(0.8)
            }).disposed(by: bag)
    
        rx.controlEvent([.touchUpInside, .touchUpOutside, .touchCancel])
            .subscribe(onNext: { [unowned self] in
                self.backgroundColor  = .white
            }).disposed(by: bag)
        
        priceBackground.layer.cornerRadius = 12
        apply(style: .purchaseButton)
    }
    
    func set(purchased: Bool) {
        if purchased {
            priceBackground.backgroundColor = .srLightGray
            priceSubtitle.isHidden = true
            price.textColor = .srViolet2
            price.text = "Your Plan"
        } else {
            priceBackground.backgroundColor = .srViolet2
            priceSubtitle.isHidden = false
            price.textColor = .white
        }
    }
}

extension Reactive where Base: ScansPurchaseButton {
    var price: AnyObserver<String> {
        return AnyObserver<String>(onNext: { [unowned base] price in
            base.price.text = price
            base.activityIndicator.stopAnimating()
        })
    }
}
