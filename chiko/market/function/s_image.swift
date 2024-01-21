//
//  s_image.swift
//  market
//
//  Created by Busan Dynamic on 2023/10/18.
//

import UIKit
import Nuke
import SDWebImage
import ImageSlideshow
import BSImagePicker
import Photos

extension UIImage {
    
    func resize(to targetSize: CGSize) -> UIImage {
        UIGraphicsImageRenderer(size: targetSize).image { _ in
            self.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }
}

func setImageSlideShew(imageView: ImageSlideshow, imageUrls: [String], cornerRadius: CGFloat = 0, contentMode: UIView.ContentMode = .scaleAspectFill) {
    
    SDImageCache.shared.clearMemory()
    SDImageCache.shared.clearDisk()
    
    imageView.layer.cornerRadius = cornerRadius
    imageView.clipsToBounds = true
    imageView.contentScaleMode = contentMode
    
    var images: [SDWebImageSource] = []
    for imageUrl in imageUrls { images.append(SDWebImageSource(urlString: imageUrl)!) }
    
    imageView.setImageInputs(images)
}

func preheatImages(urls: [URL]) {
    let prefetcher = ImagePrefetcher()
    prefetcher.startPrefetching(with: urls)
}

func setNuke(imageView: UIImageView, imageUrl: String, placeholder: UIImage = UIImage(), cornerRadius: CGFloat = 0, contentMode: UIView.ContentMode = .scaleAspectFill) {
    
    ImageCache.shared.removeAll()
    
    imageView.layer.cornerRadius = cornerRadius
    imageView.clipsToBounds = true
    imageView.contentMode = contentMode
    
    if let imageUrl = URL(string: imageUrl) {
        let request = ImageRequest(url: imageUrl, processors: [ImageProcessors.Resize(size: imageView.frame.size)])
        let options = ImageLoadingOptions(placeholder: placeholder, transition: .fadeIn(duration: 0.1), contentModes: .init(success: contentMode, failure: contentMode, placeholder: contentMode))
        Nuke.loadImage(with: request, options: options, into: imageView) { response, result, error in
            if let image = response?.image { imageView.image = image } else { imageView.image = UIImage() }
        }
    } else {
        imageView.image = UIImage()
    }
}

func setDownsampledImage(imageView: UIImageView, imageUrl: String, placeholder: UIImage = UIImage(), cornerRadius: CGFloat = 0, contentMode: UIView.ContentMode = .scaleAspectFill) {
    
    imageView.layer.cornerRadius = cornerRadius
    imageView.clipsToBounds = true
    imageView.contentMode = contentMode
    
    if let imageUrl = URL(string: imageUrl) {
        
        let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        guard let imageSource = CGImageSourceCreateWithURL(imageUrl as CFURL, imageSourceOptions) else { imageView.image = UIImage(); return }

//        let maxDimensionInPixels = 200 * 8
        let downsampleOptions = [kCGImageSourceCreateThumbnailFromImageAlways: true, kCGImageSourceShouldCacheImmediately: true, kCGImageSourceCreateThumbnailWithTransform: true, kCGImageSourceThumbnailMaxPixelSize: imageView.frame.size] as CFDictionary
     
        guard let downsampledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampleOptions) else { imageView.image = UIImage(); return }
        
        imageView.image = UIImage(cgImage: downsampledImage)
    } else {
        imageView.image = UIImage()
    }
}

func imageUrlColor(imageUrl: String, point: CGPoint, completionHandler: ((UIColor) -> Void)? = nil) {
    
    guard let url = URL(string: imageUrl) else { completionHandler?(.black.withAlphaComponent(0.3)); return }

    URLSession.shared.dataTask(with: url) { data, _, error in
        
        guard error == nil, let data = data, let image = UIImage(data: data) else { completionHandler?(.black.withAlphaComponent(0.3)); return }

        DispatchQueue.main.async {
            
            guard let cgImage = image.cgImage else { completionHandler?(.black.withAlphaComponent(0.3)); return }
            
            let width = cgImage.width
            let height = cgImage.height

            let bytesPerPixel = 4
            let bytesPerRow = bytesPerPixel * width
            let bitsPerComponent = 8
            var pixelData = [UInt8](repeating: 0, count: bytesPerPixel)
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            
            guard let context = CGContext(data: &pixelData, width: 1, height: 1, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue) else {
                completionHandler?(.black.withAlphaComponent(0.3)); return
            }
            
            context.translateBy(x: -point.x, y: -point.y)
            context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
            
            let r = CGFloat(pixelData[0]) / 255
            let g = CGFloat(pixelData[1]) / 255
            let b = CGFloat(pixelData[2]) / 255
            let a = CGFloat(pixelData[3]) / 255
            
            completionHandler?(UIColor(red: r, green: g, blue: b, alpha: a))
        }
    }.resume()
}

func imageUrlHeight(imageUrl: String, completionHandler: ((CGFloat) -> Void)? = nil) {
    
    guard let url = URL(string: imageUrl) else { completionHandler?(.zero); return }

    URLSession.shared.dataTask(with: url) { data, response, error in
        
        guard error == nil, let data = data, let image = UIImage(data: data) else { completionHandler?(.zero); return }

        DispatchQueue.main.async {
            
            let viewWidth: CGFloat = UIScreen.main.bounds.width
            let aspectRatio = image.size.width / image.size.height
            let newHeight = viewWidth / aspectRatio
//            let newSize = CGSize(width: viewWidth, height: newHeight)
            
            completionHandler?(newHeight)
        }
    }.resume()
}

func imageUrlStringToData(from urlString: String, completion: @escaping (Data?) -> Void) {
    
    guard let url = URL(string: urlString) else { completion(nil); return }
    
    URLSession.shared.dataTask(with: url) { data, _, error in
        guard let imageData = data, error == nil else { completion(nil); return }
        completion(imageData)
    }.resume()
}

extension UIViewController {
    
    func setPhoto(max: Int?, completionHandler: @escaping (([(file_name: String, file_data: Data, file_size: Int)]) -> Void)) {
        
        PHPhotoLibrary.requestAuthorization({ status in
            if (status == .authorized) {
                
                var photos: [(file_name: String, file_data: Data, file_size: Int)] = []
                
                let imagePicker = ImagePickerController()
                imagePicker.settings.selection.max = max ?? 1
                if (max ?? 1 > 1) {
                    imagePicker.settings.theme.selectionStyle = .numbered
                } else {
                    imagePicker.settings.theme.selectionStyle = .checked
                }
                imagePicker.settings.fetch.assets.supportedMediaTypes = [.image]
                if #available(iOS 13.0, *) { imagePicker.settings.theme.backgroundColor = .systemBackground } else { imagePicker.settings.theme.backgroundColor = .white }
                imagePicker.settings.list.cellsPerRow = { (verticalSize: UIUserInterfaceSizeClass, horizontalSize: UIUserInterfaceSizeClass) -> Int in return 4 }
                self.presentImagePicker(imagePicker, select: { asset in
                    
                    let options = PHImageRequestOptions()
                    options.isSynchronous = true
                    PHImageManager.default().requestImage(for: asset, targetSize: CGSize(width: 1024, height: 1024), contentMode: .aspectFill, options: options) { image, _ in
                        if let img = image, (img.pngData() ?? Data()).count > 26214400 {
                            self.customAlert(message: "이미지 최대 크기 25MB를 넘을 수 없습니다.", time: 1)
                        }
                    }
                }, deselect: nil, cancel: nil) { assets in
                    assets.forEach { asset in
                        
                        let options = PHImageRequestOptions()
                        options.isSynchronous = true
                        PHImageManager.default().requestImage(for: asset, targetSize: CGSize(width: 1024, height: 1024), contentMode: .aspectFill, options: options) { image, _ in
                            if let img = image, (img.pngData() ?? Data()).count <= 26214400 {
                                photos.append((
                                    file_name: (PHAssetResource.assetResources(for: asset).first?.originalFilename ?? "").lowercased(),
                                    file_data: img.pngData() ?? Data(),
                                    file_size: (img.pngData() ?? Data()).count
                                ))
                                if (assets.count == photos.count) { completionHandler(photos) }
                            }
                        }
                    }
                }
            } else {
                
                DispatchQueue.main.async {
                    
                    let alert = UIAlertController(title: "\'Market\'에서 \'설정\'을(를) 열려고 합니다.", message: nil, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in
                        if let settingUrl = URL(string: UIApplication.openSettingsURLString) { UIApplication.shared.open(settingUrl) }
                    }))
                    alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        })
    }
}

