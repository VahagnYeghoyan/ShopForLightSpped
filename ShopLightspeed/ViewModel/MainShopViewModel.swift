//
//  MainShopViewModel.swift
//  ShopLightspeed
//
//  Created by Vahagn Yeghoyan on 10/30/24.
//


import RxSwift
import RxCocoa
import RxDataSources

class MainShopViewModel {
    
    
    var productCells: Observable<[ProductCellType]> {
        return localProductCells.asObservable()
    }
    let localProductCells = BehaviorRelay<[ProductCellType]>(value: [])
    
    var loadInProgress: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    var forceUpdateFinished = PublishSubject<Void>()
    var forceUpdateRequested = PublishSubject<Void>()
    var needLoadMoreContent = PublishSubject<Void>()
    var productsIsLast = false
    var productsIsLoadingAllowed = true
    let productsLimit = 20
    
    var productsOffset: Int {
        guard let firstItem = localProductCells.value.first else { return 0 }
        if case ProductCellType.normal(cellViewModel: _) = firstItem  {
            return localProductCells.value.count
        } else {
            return 0
        }
    }
    
    let requestManager: RequestManager
    let disposeBag = DisposeBag()
    
    
    // MARK: - Init
    init(requestManager: RequestManager = RequestManager()) {
        self.requestManager = requestManager
        
        needLoadMoreContent.subscribe(onNext: { [weak self] _ in
            guard let self else { return }
            self.getProducts()
        }).disposed(by: disposeBag)
        
        forceUpdateRequested.subscribe(onNext: { [weak self] _ in
            guard let self else { return }
            self.getProducts(forceUpdate: true)
        }).disposed(by: disposeBag)
    }
    
    
    // MARK: - Methods
    func getProducts(forceUpdate: Bool = false) {
        
        loadInProgress.accept(true)
        productsIsLoadingAllowed = false
        
        if forceUpdate {
            localProductCells.accept([])
        }
        
        requestManager.getProducts(offset: productsOffset, limit: productsLimit).subscribe(onNext: { [weak self] productList in
            guard let self else { return }
            
            guard !productList.isEmpty else {
                self.productsIsLast = true
                self.loadInProgress.accept(false)
                if self.productsOffset == 0 || forceUpdate { self.localProductCells.accept([.empty]) }
                self.productsIsLoadingAllowed = true
                return
            }
            
            
            let productCells = productList.map { ProductCellType.normal(cellViewModel: ProductCellViewModel(productModel: $0)) }
            
            let sections: [ProductCellType]
            sections = self.localProductCells.value + productCells
            
            
            self.loadInProgress.accept(false)
            self.localProductCells.accept(sections)
            self.productsIsLoadingAllowed = true
            if forceUpdate {
                forceUpdateFinished.onNext(())
            }
            
        },onError: { [weak self] error in
            self?.loadInProgress.accept(false)
        }).disposed(by: disposeBag)
    }
}




