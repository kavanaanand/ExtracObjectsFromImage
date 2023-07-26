//
//  ViewController.swift
//  ExtractObjectFromImage
//
//  Created by Kavana Anand on 6/22/23.
//

import UIKit
import PhotosUI

class ViewController: UIViewController {
    private let imageView = UIImageView()
    private let objectRecognizer = ObjectRecognizer()
    private let objectVisualLookup = ObjectVisualLookup()
    private let photosButton = UIButton()
    private let maskButton = UIButton()
    private let maskPersonButton = UIButton()
    private let visualLookup = UIButton()
    private let images = ["cow", "elephant", "people", "coffee", "street", "wineglasses"]
    private var downSampledOriginalImage : CGImage?
    private let maxDimension = 150.0
}

extension ViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        objectRecognizer.delegate = self
        objectVisualLookup.delegate = self
        
        photosButton.setImage(UIImage(systemName: "photo"), for: .normal)
        photosButton.addTarget(self, action: #selector(photosButtonTapped), for: .touchUpInside)
        view.addSubview(photosButton)
        
        maskButton.setTitle("Mask all", for: .normal)
        maskButton.setImage(UIImage(systemName: "dot.square.fill"), for: .normal)
        maskButton.setTitleColor(.systemBlue, for: .normal)
        maskButton.addTarget(self, action: #selector(maskButtonTapped), for: .touchUpInside)
        maskButton.isEnabled = false
        view.addSubview(maskButton)
        
        maskPersonButton.setTitle("Mask people", for: .normal)
        maskPersonButton.setImage(UIImage(systemName: "dot.square"), for: .normal)
        maskPersonButton.setTitleColor(.systemBlue, for: .normal)
        maskPersonButton.addTarget(self, action: #selector(maskPersonButtonTapped), for: .touchUpInside)
        view.addSubview(maskPersonButton)
        
        visualLookup.setTitle("Lookup", for: .normal)
        visualLookup.setImage(UIImage(systemName: "info.circle"), for: .normal)
        visualLookup.setTitleColor(.systemBlue, for: .normal)
        visualLookup.addTarget(self, action: #selector(visualLookupButtonTapped), for: .touchUpInside)
        view.addSubview(visualLookup)
        
        imageView.backgroundColor = .orange
        imageView.isUserInteractionEnabled = true
        imageView.contentMode = UIView.ContentMode.scaleAspectFit
        imageView.addInteraction(objectVisualLookup.imageInteraction())
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped(_:)))
        imageView.addGestureRecognizer(tapGesture)
        view.addSubview(imageView)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        photosButton.translatesAutoresizingMaskIntoConstraints = false
        maskButton.translatesAutoresizingMaskIntoConstraints = false
        maskPersonButton.translatesAutoresizingMaskIntoConstraints = false
        visualLookup.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            photosButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            photosButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 40),
            photosButton.heightAnchor.constraint(equalToConstant: 40),
            photosButton.widthAnchor.constraint(equalToConstant: 40),
            maskButton.leadingAnchor.constraint(equalTo: photosButton.trailingAnchor, constant: 10),
            maskButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 40),
            maskButton.heightAnchor.constraint(equalToConstant: 40),
            maskPersonButton.leadingAnchor.constraint(equalTo: maskButton.trailingAnchor, constant: 10),
            maskPersonButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 40),
            maskPersonButton.heightAnchor.constraint(equalToConstant: 40),
            visualLookup.leadingAnchor.constraint(equalTo: maskPersonButton.trailingAnchor, constant: 10),
            visualLookup.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            visualLookup.topAnchor.constraint(equalTo: view.topAnchor, constant: 40),
            visualLookup.heightAnchor.constraint(equalToConstant: 40),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            imageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40),
        ])
        
//        var index = 0
//        Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { [self] timer in
//            guard index < images.count else {
//                timer.invalidate()
//                return
//            }
//            imageView.image = UIImage(named: images[index])
//            getObjects()
//            index = index + 1
//        }
    }
}

private extension ViewController {
    private func getObjects(at location: CGPoint?) {
        if let image = imageView.image {
            objectRecognizer.recognizeObjects(image.cgImage, at: location)
        }
    }
    
    private func getPeople() {
        if let image = imageView.image {
            objectRecognizer.recognizePeople(image.cgImage)
        }
    }
    
    private func lookupObjects() {
        if let image = imageView.image {
            objectVisualLookup.analyze(image)
        }
    }
    
    @objc private func photosButtonTapped() {
        var configuration = PHPickerConfiguration(photoLibrary: .shared())
        configuration.filter = .images
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    @objc private func maskButtonTapped() {
        photosButton.isEnabled = false
        maskButton.isEnabled = false
        getObjects(at: nil)
    }
    
    @objc private func maskPersonButtonTapped() {
        getPeople()
    }
    
    @objc private func visualLookupButtonTapped() {
        lookupObjects()
    }
    
    @objc func imageTapped(_ sender: UITapGestureRecognizer) {
        guard let image = imageView.image else {
            return
        }
        
        print("image size: ", image.size)
        print("image view frame: ", imageView.bounds)
        
        let location = sender.location(in: imageView)
        let scale: CGFloat
        
        if image.size.width > image.size.height {
            scale = imageView.bounds.width / image.size.width
        } else {
            scale = imageView.bounds.height / image.size.height
        }
        
        let size = CGSize(width: image.size.width * scale, height: image.size.height * scale)
        let x = (imageView.bounds.width - size.width) / 2.0
        let y = (imageView.bounds.height - size.height) / 2.0
        
        let imagePosition = CGRect(x: x, y: y, width: size.width, height: size.height)
        
        print("image position in image view", imagePosition)
        print("image view tap position: ", location)
        
        guard imagePosition.contains(location) else {
            return
        }
        
        let tapLocationOnImage = CGPoint(x: (location.x - imagePosition.minX)/scale, y: (location.y - imagePosition.minY)/scale)
        print("image tap position", tapLocationOnImage)
        
        let normalizedLocation = CGPoint(x: tapLocationOnImage.x / image.size.width, y: tapLocationOnImage.y / image.size.height)
        print("image tap normalized position", normalizedLocation)
        getObjects(at: normalizedLocation)
    }
}


extension ViewController: PHPickerViewControllerDelegate {
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true)
        
        for result in results {
            guard result.assetIdentifier != nil else {
                return
            }
            
            if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                result.itemProvider.loadObject(ofClass: UIImage.self) {[self] image, error in
                    if let image = image as? UIImage {
                        DispatchQueue.main.async { [self] in
//                            let name = result.itemProvider.suggestedName ?? "tempImage"
//                            let object = image
//                            // Downsample the image to 150 as the maximum dimension for faster result
//                            guard let imageURL = createLocalURL(for: object, name: name),
//                                  let dsImage = downsample(image: imageURL, to: CGSize(width: 150, height: 150)) else {
//                                return
//                            }
//                            downSampledOriginalImage = dsImage
//                            imageView.image = UIImage(cgImage: downSampledOriginalImage!)
                            imageView.image = image
                            maskButton.isEnabled = true
                        }
                    }
                }
            }
        }
    }
}

extension ViewController: ObjectRecognizerDelegate {
    func objectRecognizer(_ recognizer: ObjectRecognizer, didRecognizedAndMaskedObjects image: CGImage) {
        let maskImage = UIImage(cgImage: image)
        
        // INFO:
        // The following approach of downsampling is not working for grayscale cgimage
        // The createLocalURL is loosing the actual pixel value of grayscale
        // downsample() with CFData or CGDataProvider is not returning downsampled thumbnail image
        /*
        let name = "tempMaskImage"
        let object = maskImage
        guard let imageURL = createLocalURL(for: object, name: name),
              let dsImage = downsample(image: imageURL, to: CGSize(width: 150, height: 150)) else {
                  return
        }
        */
        
        let dsSize = downsampleSize(maskImage.size)
        guard let dsImage = resize(image: maskImage, size: dsSize).cgImage else {
            return
        }
        
        let pixelLocationInDownSampledMask = getFirstVisiblePixelCoordinate(dsImage)
        print(pixelLocationInDownSampledMask!)
        let pixelLocation = locationInOriginalMask(size: maskImage.size, point: pixelLocationInDownSampledMask!)
        print(pixelLocation)
        
        imageView.image = maskImage
        photosButton.isEnabled = true
        maskButton.isEnabled = true
    }
    
    func objectRecognizerDidFailRecognizingObjects(_ recognizer: ObjectRecognizer) {
        photosButton.isEnabled = true
        maskButton.isEnabled = true
    }
}

extension ViewController: ObjectVisualLookupDelegate {
    
}

// MARK: Utilities

extension ViewController {
    
    func getFirstVisiblePixelCoordinate(_ image: CGImage) -> CGPoint? {
        for y in 0..<image.height {
            for x in 0..<image.width {
                let pixelData = image.dataProvider!.data
                let dataPtr = CFDataGetBytePtr(pixelData)
                
                let bytesPerRow = image.bytesPerRow
                let bytesPerPixel = image.bitsPerPixel / 8
                let pixelOffset = y * bytesPerRow + x * bytesPerPixel
                let value = dataPtr![pixelOffset]
//                print(value)
                if (value != 0) {
                    print("(", x, ",", y , ")", " -> ", value)
                    return CGPoint(x: x, y: y)
                }
            }
        }
        print("END")
        return CGPoint(x: -1, y: -1)
    }
    
    private func locationInOriginalMask(size: CGSize, point: CGPoint) -> CGPoint {
        var scale = 1.0
        if size.width > size.height {
            scale = maxDimension / size.width
        } else {
            scale = maxDimension / size.height
        }
        return CGPoint(x: Int(point.x / CGFloat(scale)), y: Int(point.y / CGFloat(scale)))
    }
    
    private func downsampleSize(_ size: CGSize) -> CGSize {
        if size.width > size.height {
            let scale = maxDimension / size.width
            return CGSize(width: maxDimension, height: size.height * scale)
        } else {
            let scale = maxDimension / size.height
            return CGSize(width: size.width * scale, height: maxDimension)
        }
    }
    
    // This could be expensive
    private func resize(image: UIImage, size: CGSize)-> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        let resizedImage = renderer.image { context in
            image.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        }
        return resizedImage
    }
    
    /* References
     WWDC session - https://developer.apple.com/videos/play/wwdc2018/416/?time=1373
     */
    private func downsample(image imageURL: URL, to size: CGSize, scale: CGFloat = UIScreen.main.scale) -> CGImage? {
        guard let imageSource = CGImageSourceCreateWithURL(imageURL as CFURL, nil) else {
            return nil
        }
        
        let pixelDimension = max(size.width, size.height) * scale
        let options: [NSString: Any] = [
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceThumbnailMaxPixelSize: pixelDimension,
        ]
        
        guard let downsampledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, options as CFDictionary) else {
            return nil
        }
        
        return downsampledImage
    }
    
    private func createLocalURL(for image: UIImage, name: String, imageExtension: String = "png") -> URL? {
        guard let imageURL = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("\(name).\(imageExtension)") else {
            return nil
        }
        let data = image.pngData()
        do {
            try data?.write(to: imageURL);
        } catch {
            print(error)
            return nil
        }
        return imageURL
    }
}

