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
        if let entity = self.entity(at: tapLocation) as? ModelEntity {
            
            switch entity.name {
            case "topLeft":
                ModelEntity.loadModelAsync(named: "ttt_o")
                    .sink(receiveCompletion: { completion in
                        switch completion {
                        case .failure(let err): print(err.localizedDescription)
                        default: return
                        }
                    }, receiveValue: { [weak self] oEntity in
                        //entity.generateCollisionShapes(recursive: true)
                        // x: -46, 0.274, 46,
                        // z: -44, 3, 51 (posht)
                        //entity.position = [[-46, 0.274, 46].randomElement()!, 0, [-44, 3, 51].randomElement()!]
                        entity.addChild(oEntity)
                        //self?.boardEntity.addChild(entity)
                    })
                    .store(in: &cancellables)
                
                
            case "topCenter":
                
                ModelEntity.loadModelAsync(named: "ttt_x")
                    .sink(receiveCompletion: { completion in
                        switch completion {
                        case .failure(let err): print(err.localizedDescription)
                        default: return
                        }
                    }, receiveValue: { [weak self] xEntity in
                        //entity.generateCollisionShapes(recursive: true)
                        // x: -46, 0.274, 46,
                        // z: -44, 3, 51 (posht)
                        //entity.position = [[-46, 0.274, 46].randomElement()!, 0, [-44, 3, 51].randomElement()!]
                        entity.addChild(xEntity)
                        //self?.boardEntity.addChild(entity)
                    })
                    .store(in: &cancellables)
                
//                ModelEntity.loadModelAsync(named: "ttt_o")
//                    .sink(receiveCompletion: { completion in
//                        switch completion {
//                        case .failure(let err): print(err.localizedDescription)
//                        default: return
//                        }
//                    }, receiveValue: { [weak self] entity in
//                        entity.name = "board"
//                        entity.generateCollisionShapes(recursive: true)
//                        // x: -46, 0.274, 46,
//                        // z: -44, 3, 51 (posht)
//                        entity.position = [[-46, 0.274, 46].randomElement()!, 0, [-44, 3, 51].randomElement()!]
//
//                        self?.boardEntity.addChild(entity)
//                    })
//                    .store(in: &cancellables)
            default: return
            }
            
           
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
                
                let rectangle = MeshResource.generatePlane(width: 45.66, depth: 45.66)
                let material = SimpleMaterial(color: .red, isMetallic: false)
                
                let tapEntity = ModelEntity(mesh: rectangle, materials: [material])
                tapEntity.generateCollisionShapes(recursive: true)
                tapEntity.name = "topLeft"
                //tapEntity.position = [[-46, 0.274, 46].randomElement()!, 0, [-44, 3, 51].randomElement()!]
                tapEntity.position = [-46, 0, -44]
                anchor.addChild(tapEntity)
                
                let material2 = SimpleMaterial(color: .green, isMetallic: false)
                let tapEntity2 = ModelEntity(mesh: rectangle, materials: [material2])
                tapEntity2.generateCollisionShapes(recursive: true)
                tapEntity2.name = "topCenter"
                tapEntity2.position = [0.274, 0, -44]
                anchor.addChild(tapEntity2)
                
                self?.scene.addAnchor(anchor)
                self?.boardEntity = entity
            })
            .store(in: &cancellables)
    }
}

