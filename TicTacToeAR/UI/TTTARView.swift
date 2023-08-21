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
    required init(frame frameRect: CGRect) {
        super.init(frame: frameRect)
    }
    
    dynamic required init?(coder decoder: NSCoder) {
        fatalError("not used")
    }
    
    convenience init() {
        self.init(frame: UIScreen.main.bounds)
        setup()
    }
    
    private var cancellables: Set<AnyCancellable> = []
    private var boardEntity: ModelEntity!
    
    @objc private func viewTapped(_ recognizer: UITapGestureRecognizer) {
        let tapLocation = recognizer.location(in: self)
        if let entity = self.entity(at: tapLocation) as? ModelEntity, entity.name == "board" {
            ModelEntity.loadModelAsync(named: "ttt_o")
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .failure(let err): print(err.localizedDescription)
                    default: return
                    }
                }, receiveValue: { [weak self] entity in
                    entity.name = "board"
                    entity.generateCollisionShapes(recursive: true)
                    // x: -46, 0.274, 46,
                    // z: -44, 3, 51 (posht)
                    entity.position = [[-46, 0.274, 46].randomElement()!, 0, [-44, 3, 51].randomElement()!]
                    
                    self?.boardEntity.addChild(entity)
                })
                .store(in: &cancellables)
        }
    }
    
    private func setup() {
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewTapped)))
        
        let anchor = AnchorEntity(plane: .horizontal, minimumBounds: [0.2, 0.2])
        anchor.setScale(SIMD3<Float>(0.002, 0.002, 0.002), relativeTo: anchor)
        ModelEntity.loadModelAsync(named: "ttt_board")
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let err): print(err.localizedDescription)
                default: return
                }
            }, receiveValue: { [weak self] entity in
                entity.name = "board"
                entity.generateCollisionShapes(recursive: true)
                anchor.addChild(entity)
                self?.scene.addAnchor(anchor)
                self?.boardEntity = entity
            })
            .store(in: &cancellables)
    }
}

