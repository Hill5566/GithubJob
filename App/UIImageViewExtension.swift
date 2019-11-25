
import Foundation
import UIKit
import Kingfisher

public struct BeforeCompletionProcessor: ImageProcessor {
    
    public let identifier = "processor"
    var callback:(Image?)->()
    public init(_ beforeCompletion: @escaping (Image?) -> ()) {
        callback = beforeCompletion
    }
    public func process(item: ImageProcessItem, options: KingfisherParsedOptionsInfo) -> Image? {
        switch item {
        case .image(let image):
            callback(image)
            return image
        case .data(_):
            return (DefaultImageProcessor() >> self).process(item: item, options: options)
        }
    }
}
extension UIImageView {
//    public func setImageAsyncFrom(urlString:String,_ callback:(()->())? = nil){
//        let url = URL(string: urlString)
//        if let validUrl = url{
//            self.setImageAsyncFrom(url:validUrl,callback)
//        }else{
//            self.contentMode = UIView.ContentMode.center
//            self.image = UIImage(named:"imagenotfound")
//        }
//    }
    public func setImageAsyncFrom(urlString:String, contentMode: UIView.ContentMode = .scaleAspectFit,_ callback: (()->())? = nil) {
        let url = URL(string: urlString)
        if let validUrl = url {
            self.setImageAsyncFrom(url:validUrl, contentMode: contentMode, callback)
        }else{
            self.contentMode = UIView.ContentMode.center
            self.image = UIImage(named:"iconsIcPicfail")
        }
    }

    public func setImageAsyncFrom(url:URL, contentMode: UIView.ContentMode = .scaleAspectFill,_ callback: (()->())? = nil){
        let cache = ImageCache.default
        cache.memoryStorage.config.expiration = .days(1)
        
        let beforeCompletion = BeforeCompletionProcessor({
            downloadImage in
            DispatchQueue.main.async { [weak self] in
                if downloadImage != nil{
                    self?.contentMode = contentMode
                }else{
                    self?.contentMode = UIView.ContentMode.center
                }
            }
        })
        //        let placeholder = CachedAssets.preloader
        self.contentMode = UIView.ContentMode.center
        self.image = nil
        self.kf.setImage(with: url, placeholder: UIImage(named: "iconsIcPicfail"), options: [.processor(beforeCompletion), .targetCache(cache)], progressBlock: nil) { [weak self] (result) in
            if (try? result.get().image) != nil {
                self?.contentMode = contentMode
            } else {
                self?.contentMode = UIView.ContentMode.center
                self?.image = UIImage(named: "iconsIcPicfail")
            }
            if let cb = callback {
                cb()
            }
        }
    }
}
