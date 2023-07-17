//
//  ObjectRecognizer.swift
//  ExtractObjectFromImage
//
//  Created by Kavana Anand on 7/10/23.
//

import Vision
import CoreImage
import CoreImage.CIFilterBuiltins

protocol ObjectRecognizerDelegate: AnyObject {
    func objectRecognizer(_ recognizer: ObjectRecognizer, didRecognizedAndMaskedObjects image: CGImage)
    func objectRecognizerDidFailRecognizingObjects(_ recognizer: ObjectRecognizer)
}

class ObjectRecognizer: NSObject {
    
    required override init() {
        super.init()
    }
    
    func recognizePeople(_ cgImage: CGImage?) {
        guard cgImage != nil else {
            return
        }
        
        let requestHandler = VNImageRequestHandler(cgImage: cgImage!)
        
        // Execute Vision request
        let request = VNGeneratePersonSegmentationRequest { [self] request, error in
            guard let result = request.results?.first as? VNPixelBufferObservation, error == nil else {
                delegate?.objectRecognizerDidFailRecognizingObjects(self)
                return
            }
            
            let mask = CIImage(cvPixelBuffer: result.pixelBuffer)
            processResult(mask: mask, toImage: cgImage!)
        }
        
        do {
            try requestHandler.perform([request])
        } catch {
            print(error)
        }
    }
    
    func recognizeObjects(_ cgImage: CGImage?, at tapPosition: CGPoint?) {
        guard cgImage != nil else {
            return
        }
        
        let requestHandler = VNImageRequestHandler(cgImage: cgImage!)
        
        // Execute Vision request
        let request = VNGenerateForegroundInstanceMaskRequest { [self] request, error in
            guard let result = request.results?.first as? VNInstanceMaskObservation else {
                delegate?.objectRecognizerDidFailRecognizingObjects(self)
                return
            }
            
            do {
                // Find the instances at tap position
                var instances : IndexSet
                if tapPosition == nil  {
                    instances = result.allInstances
                } else {
                    let mask = result.instanceMask
                    let coords = VNImagePointForNormalizedPoint(tapPosition!, CVPixelBufferGetWidth(mask) - 1, CVPixelBufferGetHeight(mask) - 1)
                    
                    CVPixelBufferLockBaseAddress(mask, .readOnly)
                    let pixels = CVPixelBufferGetBaseAddress(mask)!
                    let bytesPerRow = CVPixelBufferGetBytesPerRow(mask)
                    let instanceLabel = pixels.load(fromByteOffset: Int(coords.y) * bytesPerRow + Int(coords.x), as: UInt8.self)
                    CVPixelBufferUnlockBaseAddress(mask, .readOnly)
                    
                    instances = instanceLabel == 0 ? result.allInstances : [Int(instanceLabel)]
                }
                
                // Generate mask
                let output = try result.generateScaledMaskForImage(forInstances: instances, from: requestHandler)
                let mask = CIImage(cvPixelBuffer: output)
                processResult(mask: mask, toImage: cgImage!)
            } catch {
                delegate?.objectRecognizerDidFailRecognizingObjects(self)
                print(error)
            }
        }
        
        do {
            try requestHandler.perform([request])
        } catch {
            print(error)
        }
    }
    
    weak var delegate: ObjectRecognizerDelegate?
}

private extension ObjectRecognizer {
    private func processResult(mask: CIImage, toImage image: CGImage) {
        
        // Mask
        guard let maskCGImage = CIContext().createCGImage(mask, from: mask.extent) else {
            return
        }
        delegate?.objectRecognizer(self, didRecognizedAndMaskedObjects: maskCGImage)
        
        // Mask applied to the original image
//        let filter = CIFilter.blendWithMask()
//        filter.inputImage = CIImage(cgImage: image)
//        filter.maskImage = mask
//        filter.backgroundImage = CIImage.empty()
//        
//        guard let maskedImage = filter.outputImage,
//              let maskedCGImage = CIContext().createCGImage(maskedImage, from: maskedImage.extent) else {
//            delegate?.objectRecognizerDidFailRecognizingObjects(self)
//            return
//        }
//        delegate?.objectRecognizer(self, didRecognizedAndMaskedObjects: maskedCGImage)
    }
}
