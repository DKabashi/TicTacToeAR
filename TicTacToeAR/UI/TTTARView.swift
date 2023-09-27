//
//  TTTARView.swift
//  TicTacToeAR
//
//  Created by Donat Kabashi on 8/21/23.
//

import ARKit
import RealityKit
import SwiftUI
import UIKit
import Combine

class TTTARView: ARView {
    var viewModel: TTTViewModel

    init(viewModel: TTTViewModel) {
        self.viewModel = viewModel
        super.init(frame: UIScreen.main.bounds)
        setup()
    }
    
    private func setup() {
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewTapped)))
        viewModel.addBoardEntity(in: scene, arView: self)
        viewModel.restartGameAction = restartGame
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            self.removeEditBoardGestures()
        }
    }
    
    private func restartGame() {
        guard let gameAnchor = viewModel.gameAnchor else { return }
        scene.removeAnchor(gameAnchor)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let self = self else { return }
            self.viewModel.addBoardEntity(in: self.scene, arView: self)
            self.viewModel.gameAnchor = nil
        }
    }
    
    private func removeEditBoardGestures() {
        for gesture in (self.gestureRecognizers ?? []) where
            gesture is RealityKit.EntityScaleGestureRecognizer ||
            gesture is RealityKit.EntityRotationGestureRecognizer ||
            gesture is RealityKit.EntityTranslationGestureRecognizer {
            self.removeGestureRecognizer(gesture)
        }
    }

    @objc private func viewTapped(_ recognizer: UITapGestureRecognizer) {
        let tapLocation = recognizer.location(in: self)
        if viewModel.gameAnchor == nil {
            let results = raycast(from: tapLocation,
                                         allowing: .estimatedPlane,
                                         alignment: .horizontal)
            if let result = results.first {
                let anchorEntity = AnchorEntity(world: result.worldTransform)
                anchorEntity.setScale(SIMD3<Float>(0.002, 0.002, 0.002), relativeTo: anchorEntity)
                anchorEntity.addChild(viewModel.boardEntity)
//                for position in XOPosition.allCases {
//                    viewModel.generateTapEntity(in: position, anchor: anchorEntity)
//                }
                
                scene.addAnchor(anchorEntity)
                viewModel.gameAnchor = anchorEntity
            }
            return
        }
        guard !viewModel.isGameOver else { return }
        if let entity = self.entity(at: tapLocation) as? ModelEntity, let position = XOPosition(rawValue: entity.name) {
            viewModel.addXOEntity(in: entity, at: position)
        }
    }

    dynamic required init?(coder decoder: NSCoder) {
        fatalError("not used")
    }
    
    required init(frame frameRect: CGRect) {
        fatalError("init(frame:) has not been implemented")
    }
}
