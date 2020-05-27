//
//  GraphsViewModel.swift
//  SmartReceipts
//
//  Created Bogdan Evsenev on 04.04.2020.
//  Copyright © 2020 Will Baumann. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

protocol GraphsViewModelProtocol {
    var dataSet: Observable<ChartDataSetProtocol> { get }
    var routeObserver: AnyObserver<GraphsRouter.Route> { get }
    var trip: WBTrip { get }
    func moduleDidLoad()
}

class GraphsViewModel: GraphsViewModelProtocol {
    private var router: GraphsRouterProtocol
    private let bag = DisposeBag()
    let trip: WBTrip
    
    let dataSetSubject: BehaviorSubject<ChartDataSetProtocol>
    var dataSet: Observable<ChartDataSetProtocol> {
        return dataSetSubject.asObservable()
    }
    
    let routeRelay: PublishSubject<GraphsRouter.Route> = .init()
    var routeObserver: AnyObserver<GraphsRouter.Route> {
        return routeRelay.asObserver()
    }
    
    init(router: GraphsRouterProtocol, trip: WBTrip) {
        self.router = router
        self.trip = trip
        let emptyDataSet = GraphsCategoryDataSet(data: [])
        self.dataSetSubject = .init(value: emptyDataSet)
    }

    func moduleDidLoad() {
        bind()
        switchModel(to: .categories)
        switchPeriod(to: .report)
    }
    
    private func bind() {
        routeRelay.filterCases(cases: .close)
            .subscribe(onNext: { [weak self] _ in self?.router.close() })
            .disposed(by: bag)
        
        routeRelay
            .filterCases(cases: .period)
            .flatMap { [weak self] _ in self?.router.openPeriod() ?? .never() }
            .subscribe(onNext: { [weak self] in self?.switchPeriod(to: $0) })
            .disposed(by: bag)
        
        routeRelay
            .filterCases(cases: .model)
            .flatMap { [weak self] _ in self?.router.openModel() ?? .never() }
            .subscribe(onNext: { [weak self] in self?.switchModel(to: $0) })
            .disposed(by: bag)
    }
    
    // MARK: - PRIVATE
    
    private func switchPeriod(to selection: GraphsAssembly.PeriodSelection) {
        
    }
    
    private func switchModel(to selection: GraphsAssembly.ModelSelection) {
        switch selection {
        case .categories: dataSetSubject.onNext(categoryDataSet)
        case .paymentMethods: dataSetSubject.onNext(paymentMethodDataSet)
        case .dates: dataSetSubject.onNext(daysDataSet)
        }
    }
    
    private var categoryDataSet: ChartDataSetProtocol {
        let receipts = (Database.sharedInstance().allReceipts(for: trip) ?? []) as [WBReceipt]
        let categories = Set(receipts.compactMap { $0.category })
        let data = categories.map { category -> GraphsCategoryDataSet.GraphsCategoryData? in
            let price = PricesCollection(currencyCode: trip.defaultCurrency.code)
            let cReceipts = receipts.filter { $0.category?.code == category.code }
            cReceipts.forEach { price.addPrice($0.price()) }
            return .init(category: category, total: price)
        }.compactMap { $0 }
        return GraphsCategoryDataSet(data: data)
    }
    
    private var paymentMethodDataSet: ChartDataSetProtocol {
        let receipts = (Database.sharedInstance().allReceipts(for: trip) ?? []) as [WBReceipt]
        let paymentMethods = Set(receipts.compactMap { $0.paymentMethod })
        let data = paymentMethods.map { method -> GraphsPaymentMethodDataSet.GraphsPaymentMethodData in
            let price = PricesCollection(currencyCode: trip.defaultCurrency.code)
            let pmReceipts = receipts.filter { $0.paymentMethod == method}
            pmReceipts.forEach { price.addPrice($0.price()) }
            return .init(paymentMethod: method, total: price)
        }
        return GraphsPaymentMethodDataSet(data: data)
    }
    
    private var daysDataSet: ChartDataSetProtocol {
        let receipts = (Database.sharedInstance().allReceipts(for: trip) ?? []) as [WBReceipt]
        let days = Set(receipts.map { $0.date.dayString() })
        let data = days.map { day -> GraphsDaysDataSet.GraphsDaysData in
            let price = PricesCollection(currencyCode: trip.defaultCurrency.code)
            let dayReceipts = receipts.filter { $0.date.dayString() == day }
            dayReceipts.forEach { price.addPrice($0.price()) }
            return .init(day: day, total: price)
        }
        return GraphsDaysDataSet(data: data)
    }
}

