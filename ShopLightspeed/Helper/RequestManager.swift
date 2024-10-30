//
//  RequestManager.swift
//  ShopLightspeed
//
//  Created by Vahagn Yeghoyan on 10/30/24.
//

import RxSwift
import RxCocoa


enum FailureReason: String, Error {
    case unknown    = "UNKNOWN"
    case unparsable = "UNPARSABLE"
    case noInternet = "NOINTERNETCONNECTION"
}


class RequestManager {
    
    let disposeBag = DisposeBag()
    
    func getProducts(offset: Int, limit: Int) -> Observable<[ProductModel]> {
        var components = URLComponents(string: UrlHelper.getProductsUrl)

        components?.queryItems = [
            URLQueryItem(name: "skip", value: "\(offset)"),
            URLQueryItem(name: "limit", value: "\(limit)")
        ]
        return URLSession.shared.rx
            .data(request: URLRequest(url: components!.url!))
            .map { data -> [ProductModel] in
                let productContainer = try JSONDecoder().decode(ProductContainer.self, from: data)
                return productContainer.products
            }
    }
}
