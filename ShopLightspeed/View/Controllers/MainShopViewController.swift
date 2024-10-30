//
//  MainShopViewController.swift
//  ShopLightspeed
//
//  Created by Vahagn Yeghoyan on 10/30/24.
//

import RxSwift
import RxCocoa

class MainShopViewController: UIViewController {
    
    
    // MARK: - IBOutlets
    @IBOutlet weak var mainTableView: UITableView!
    @IBOutlet weak var mainLoadingActivity: UIActivityIndicatorView!
    
    
    // MARK: - ViewModel
    let viewModel = MainShopViewModel()
    let refreshControl = UIRefreshControl()

    
    // MARK: - LifeCycle Methods
    override func viewDidLoad() {
        
        uiConfiguration()
        bindings()
        tableViewBottoCheck()
    }
    
    
    // MARK: - Standard Methods
    private func uiConfiguration() {
        regisiterCell()
        refreshControlConfig()
        loadingConfig()
        
        mainTableView.refreshControl = refreshControl
    }
    
    private func bindings() {
        bindTableViewDataSource()
        bindCellSelection()
    }
    
    // MARK: - Helper Methods
    private func refreshControlConfig() {
        refreshControl.rx.controlEvent(.valueChanged)
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                self.viewModel.forceUpdateRequested.onNext(())
            })
            .disposed(by: viewModel.disposeBag)
    }
    
    private func regisiterCell() {
        mainTableView.register(UINib(nibName: MainProductTableViewCell.id, bundle: nil), forCellReuseIdentifier: MainProductTableViewCell.id)
    }
    
    private func tableViewBottoCheck() {
        mainTableView.rx.contentOffset
            .observe(on: MainScheduler.instance)
            .filter { [weak self] _ in
                guard let self else { return false }
                return self.isReachedTheEnd()
            }
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                self.viewModel.needLoadMoreContent.onNext(())
            })
            .disposed(by: viewModel.disposeBag)
    }
    
    private func loadingConfig() {
        viewModel.loadInProgress.subscribe(onNext: { value in 
            
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                value ? self.mainLoadingActivity.startAnimating() : self.mainLoadingActivity.stopAnimating()
            }
        }).disposed(by: viewModel.disposeBag)
        
        
        viewModel.forceUpdateFinished.subscribe(onNext: { _ in
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.refreshControl.endRefreshing()
            }
        }).disposed(by: viewModel.disposeBag)
    }
    
    private func isReachedTheEnd() -> Bool {
        let contentHeight = mainTableView.contentSize.height
        let tableViewHeight = mainTableView.bounds.size.height
        let offsetY = mainTableView.contentOffset.y
        
        return (offsetY + tableViewHeight + 50) > contentHeight && viewModel.productsIsLoadingAllowed
    }
}


// MARK: - Extensions



// MARK: - TableView Methods
extension MainShopViewController {
    private func bindTableViewDataSource() {
        
        viewModel.localProductCells
            .bind(to: mainTableView.rx.items) { [unowned self] (tableView, row, item) in
                let indexPath = IndexPath(item: row, section: 0)
                return self.makeCell(with: item, from: tableView, indexPath: indexPath)
            }.disposed(by: viewModel.disposeBag)
    }
    
    private func bindCellSelection() {
        mainTableView.rx.itemSelected.subscribe(
            onNext: { indexPath in
                print("Tapped on \(indexPath.row)")
            }).disposed(by: viewModel.disposeBag)
    }
    
    private func makeCell(with element: ProductCellType, from collectionView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        
        switch element {
        case .normal(let cellViewModel):
                let cell = mainTableView.dequeueReusableCell(withIdentifier: MainProductTableViewCell.id, for: indexPath) as! MainProductTableViewCell
            
                cell.viewModel = cellViewModel
            cell.isHidden = false
            
            return cell
        default:
                let cell = mainTableView.dequeueReusableCell(withIdentifier: MainProductTableViewCell.id, for: indexPath) as! MainProductTableViewCell
            cell.isHidden = true
            return cell
        }
    }
}
