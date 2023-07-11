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
    private let photosButton = UIButton()
    private let recognizeButton = UIButton()
    private let images = ["cow", "elephant", "people", "coffee", "street", "wineglasses"];
}

extension ViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        objectRecognizer.delegate = self
        
        photosButton.setImage(UIImage(systemName: "photo"), for: .normal)
        photosButton.addTarget(self, action: #selector(photosButtonTapped), for: .touchUpInside)
        view.addSubview(photosButton)
        
        recognizeButton.setTitle(" Recognize objects", for: .normal)
        recognizeButton.setImage(UIImage(systemName: "info.circle"), for: .normal)
        recognizeButton.setTitleColor(.systemBlue, for: .normal)
        recognizeButton.addTarget(self, action: #selector(recognizeobjectsButtonTapped), for: .touchUpInside)
        recognizeButton.isEnabled = false
        view.addSubview(recognizeButton)
        
        imageView.backgroundColor = .orange
        imageView.isUserInteractionEnabled = true
        imageView.contentMode = UIView.ContentMode.scaleAspectFit
        view.addSubview(imageView)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped(_:)))
        imageView.addGestureRecognizer(tapGesture)
        
        photosButton.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        recognizeButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            photosButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            photosButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 40),
            photosButton.heightAnchor.constraint(equalToConstant: 40),
            photosButton.widthAnchor.constraint(equalToConstant: 40),
            recognizeButton.leadingAnchor.constraint(equalTo: photosButton.trailingAnchor, constant: 10),
            recognizeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            recognizeButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 40),
            recognizeButton.heightAnchor.constraint(equalToConstant: 40),
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
    
    @objc private func photosButtonTapped() {
        var configuration = PHPickerConfiguration(photoLibrary: .shared())
        configuration.filter = .images
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    @objc private func recognizeobjectsButtonTapped() {
        photosButton.isEnabled = false
        recognizeButton.isEnabled = false
        getObjects(at: nil)
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
                result.itemProvider.loadObject(ofClass: UIImage.self) { [self] image, error in
                    DispatchQueue.main.async {
                        let object = image as! UIImage
                        self.imageView.image = object
                        self.recognizeButton.isEnabled = true
                    }
                }
            }
        }
    }
}

extension ViewController: ObjectRecognizerDelegate {
    func objectRecognizer(_ recognizer: ObjectRecognizer, didRecognizedAndMaskedObjects image: CGImage) {
        imageView.image = UIImage(cgImage: image)
        photosButton.isEnabled = true
        recognizeButton.isEnabled = true
    }
    
    func objectRecognizerDidFailRecognizingObjects(_ recognizer: ObjectRecognizer) {
        photosButton.isEnabled = true
        recognizeButton.isEnabled = true
    }
}




