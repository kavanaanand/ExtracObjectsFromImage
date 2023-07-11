//
//  ObjectVisualLookup.swift
//  ExtractObjectFromImage
//
//  Created by Kavana Anand on 7/11/23.
//

import VisionKit

protocol ObjectVisualLookupDelegate: AnyObject {
    
    
}

@MainActor
class ObjectVisualLookup: NSObject {
    
    required override init() {
        super.init()
        interaction.delegate = self
    }
    
    func imageInteraction() -> ImageAnalysisInteraction {
        return interaction
    }
    
    func analyze(_ image: UIImage) {
        Task {
            do {
                let analysis = try await analyzer.analyze(image, configuration: ImageAnalyzer.Configuration([.visualLookUp]))
                interaction.preferredInteractionTypes = .visualLookUp
                interaction.analysis = analysis
            } catch {
                print(error)
            }
        }
    }
    
    
    weak var delegate : ObjectVisualLookupDelegate?
    private let analyzer = ImageAnalyzer()
    private let interaction = ImageAnalysisInteraction()
}

extension ObjectVisualLookup: ImageAnalysisInteractionDelegate {
    
}
