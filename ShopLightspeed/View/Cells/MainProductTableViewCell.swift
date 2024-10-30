//
//  MainProductTableViewCell.swift
//  ShopLightspeed
//
//  Created by Vahagn Yeghoyan on 10/30/24.
//

import RxSwift
import RxCocoa
import RxDataSources

class MainProductTableViewCell: UITableViewCell {

    
    // MARK: - Id
    static let id: String = "MainProductTableViewCell"
    
    
    // MARK: - ViewModel
    var viewModel: ProductCellViewModel? {
        didSet {
            bindViewModel()
        }
    }
    
    
    // MARK: - RX
    var disposeBag = DisposeBag()
    
    
    // MARK: - IBOutlets
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var descritpionLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var mainLoadingIndicator: UIActivityIndicatorView!
    
    
    // MARK: - LifeCycle Methods
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        disposeBag = DisposeBag()
        mainLoadingIndicator.stopAnimating()
        mainImageView.image = nil
    }
    
    
    private func bindViewModel() {
        guard let viewModel else { return }
        
        configure(with: viewModel.product.images.first)
        
        idLabel.text = "Id - \(viewModel.product.id)"
        priceLabel.text = "Price - \(viewModel.product.price)"
        descritpionLabel.text = viewModel.product.description
        titleLabel.text = viewModel.product.title
        ratingLabel.text = "Rating: \(viewModel.product.rating)"
    }
    
    func configure(with url: String?) {
        guard let url, let urlChecked = URL(string: url) else { return }
        mainLoadingIndicator.startAnimating()
        
        mainImageView.loadImage(from: urlChecked)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] image in
                guard let self else { return }
                
                let modifiedImage = image?.resizeImage(targetSize: CGSize(width: 64, height: 64))
                self.mainLoadingIndicator.stopAnimating()
                self.mainImageView.image = modifiedImage
            })
            .disposed(by: disposeBag)
    }
}


struct ProductCellViewModel {
    let product: ProductModel
    
    init(productModel: ProductModel) {
        self.product = productModel
    }
}


enum ProductCellType: IdentifiableType, Equatable {
    
    static func == (lhs: ProductCellType, rhs: ProductCellType) -> Bool {
        lhs.cellViewModel?.product.id == rhs.cellViewModel?.product.id
    }
    
    typealias Identity = String
    
    case normal(cellViewModel: ProductCellViewModel)
    case error(message: String)
    case empty
    
    var cellViewModel: ProductCellViewModel? {
        switch self {
        case let .normal(cellViewModel): return cellViewModel
        default: return nil
        }
    }
   
    var identity: String {
        switch self {
            case let .normal(cellViewModel): return "\(cellViewModel.product.id)"
        default: return UUID().uuidString
        }
    }
}
