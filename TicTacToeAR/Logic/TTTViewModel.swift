//
//  TTTViewModel.swift
//  TicTacToeAR
//
//  Created by Donat Kabashi on 9/6/23.
//

import ARKit
import RealityKit
import UIKit
import Combine

class TTTViewModel {
    private var boardEntity: ModelEntity!
    private var isXTurn = true
    
    private var cancellables: Set<AnyCancellable> = []
    
    func addBoardEntity(in scene: Scene) {
        let anchor = AnchorEntity(plane: .horizontal, minimumBounds: [0.2, 0.2])
        anchor.setScale(SIMD3<Float>(0.002, 0.002, 0.002), relativeTo: anchor)
        ModelEntity.loadModelAsync(named: TTTAsset.board.rawValue)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let err): print(err.localizedDescription)
                default: return
                }
            }, receiveValue: { [weak self] entity in
                entity.name = TTTAsset.board.rawValue
                entity.generateCollisionShapes(recursive: true)
                anchor.addChild(entity)
                
                for position in XOPosition.allCases {
                    self?.generateTapEntity(in: position, anchor: anchor)
                }
                
                scene.addAnchor(anchor)
                self?.boardEntity = entity
            })
            .store(in: &cancellables)
    }
    
    
    func addXOEntity(in entity: ModelEntity, at postion: XOPosition) {
        let entityHasNoValue =  boardEntity.scene?.anchors.first?.children.first {
                $0.name == postion.rawValue
        }?.children.allSatisfy { $0.name != "checked" } ?? false
        
        guard entityHasNoValue else { return }

        ModelEntity.loadModelAsync(named: (isXTurn ? TTTAsset.x : TTTAsset.o).rawValue)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let err): print(err.localizedDescription)
                default: return
                }
            }, receiveValue: { [weak self] xoEntity in
                guard let self = self else { return }
                xoEntity.name = "checked"
                entity.addChild(xoEntity)
                self.isXTurn.toggle()
            })
            .store(in: &cancellables)
    }
    
    /// x options: [-46, 0.274, 46],
    /// z options: [-44, 3, 51]
    private func generateTapEntity(in postion: XOPosition, anchor: AnchorEntity) {
        var xPos: Float!
        var zPos: Float!

        switch postion {
        case .topLeft:
            xPos = -46
            zPos = -44
        case .topCenter:
            xPos = 0.274
            zPos = -44
        case .topRight:
            xPos = 46
            zPos = -44
        case .centerLeft:
            xPos = -46
            zPos = 3
        case .centerCenter:
            xPos = 0.274
            zPos = 3
        case .centerRight:
            xPos = 46
            zPos = 3
        case .bottomLeft:
            xPos = -46
            zPos = 51
        case .bottomCenter:
            xPos = 0.274
            zPos = 51
        case .bottomRight:
            xPos = 46
            zPos = 51
        }
        
        let rectangle = MeshResource.generatePlane(width: 45.66, depth: 45.66)
        let material = SimpleMaterial(color: .clear, isMetallic: false)
        
        let tapEntity = ModelEntity(mesh: rectangle, materials: [material])
        tapEntity.generateCollisionShapes(recursive: true)
        tapEntity.name = postion.rawValue
        tapEntity.position = [xPos, 0, zPos]
        anchor.addChild(tapEntity)
    }
}
