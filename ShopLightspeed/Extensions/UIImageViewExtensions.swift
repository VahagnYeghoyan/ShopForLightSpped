//
//  UIImageViewExtensions.swift
//  ShopLightspeed
//
//  Created by Vahagn Yeghoyan on 10/30/24.
//

import RxSwift

class ImageCache {
    static let shared = NSCache<NSURL, UIImage>()
}

extension UIImageView {
    
    func loadImage(from url: URL) -> Observable<UIImage?> {
        if let cachedImage = ImageCache.shared.object(forKey: url as NSURL) {
            return Observable.just(cachedImage)
        }
        
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.requestCachePolicy = .returnCacheDataElseLoad
        let session = URLSession(configuration: sessionConfig)
        
        return Observable<UIImage?>.create { observer in
            let task = session.dataTask(with: url) { data, _, error in
                if let error = error {
                    observer.onError(error)
                } else if let data = data, let image = UIImage(data: data) {
                    ImageCache.shared.setObject(image, forKey: url as NSURL)
                    observer.onNext(image)
                    observer.onCompleted()
                } else {
                    observer.onNext(nil)
                    observer.onCompleted()
                }
            }
            task.resume()
            return Disposables.create { task.cancel() }
        }
    }
}
