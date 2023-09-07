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
    /// Key: Position in  board,
    /// Value: True = x, false = o, nil = no value assigned yet
    private var boardValues = [XOPosition: Bool?]()
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
        }?.children.allSatisfy { $0.name != TTTAsset.x.rawValue && $0.name != TTTAsset.o.rawValue } ?? false
        
        guard entityHasNoValue else { return }

        ModelEntity.loadModelAsync(named: (isXTurn ? TTTAsset.x : TTTAsset.o).rawValue)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let err): print(err.localizedDescription)
                default: return
                }
            }, receiveValue: { [weak self] xoEntity in
                guard let self = self else { return }
                xoEntity.name = (self.isXTurn ? TTTAsset.x : TTTAsset.o).rawValue
                entity.addChild(xoEntity)
                self.boardValues[postion] = self.isXTurn
                self.checkGameStatus()
                self.isXTurn.toggle()
            })
            .store(in: &cancellables)
    }
    
    private func checkGameStatus() {
        let topLeftValue = boardValues[.topLeft]
        let topCenterValue = boardValues[.topCenter]
        let topRightValue = boardValues[.topRight]
        let centerLeftValue = boardValues[.centerLeft]
        let centerCenterValue = boardValues[.centerCenter]
        let centerRightValue = boardValues[.centerRight]
        let bottomLeftValue = boardValues[.bottomLeft]
        let bottomCenterValue = boardValues[.bottomCenter]
        let bottomRightValue = boardValues[.bottomRight]
        
        if isXTurn {
            let xWonTopHorizontal = topLeftValue == true && topCenterValue == true && topRightValue == true
            let xWonCenterHorizontal = centerLeftValue == true && centerCenterValue == true && centerRightValue == true
            let xWonBottomHorizontal = bottomLeftValue == true && bottomCenterValue == true && bottomRightValue == true
            let xWonDiagonalLeft = topLeftValue == true && centerCenterValue == true && bottomRightValue == true
            let xWonDiagonalRight = topRightValue == true && centerCenterValue == true && bottomLeftValue == true
            let xWonLeftVertical = topLeftValue == true && centerLeftValue == true && bottomLeftValue == true
            let xWonCenterVertical = topCenterValue == true && centerCenterValue == true && bottomCenterValue == true
            let xWonRightVertical = topRightValue == true && centerRightValue == true && bottomRightValue == true
            
           guard xWonTopHorizontal || xWonCenterHorizontal || xWonBottomHorizontal ||
                    xWonDiagonalLeft || xWonDiagonalRight ||
                    xWonLeftVertical || xWonCenterVertical || xWonRightVertical else {
               return
           }
           print("x won")
        } else {
            let oWonTopHorizontal = topLeftValue == true && topCenterValue == true && topRightValue == true
            let oWonCenterHorizontal = centerLeftValue == true && centerCenterValue == true && centerRightValue == true
            let oWonBottomHorizontal = bottomLeftValue == true && bottomCenterValue == true && bottomRightValue == true
            let oWonDiagonalLeft = topLeftValue == true && centerCenterValue == true && bottomRightValue == true
            let oWonDiagonalRight = topRightValue == true && centerCenterValue == true && bottomLeftValue == true
            let oWonLeftVertical = topLeftValue == true && centerLeftValue == true && bottomLeftValue == true
            let oWonCenterVertical = topCenterValue == true && centerCenterValue == true && bottomCenterValue == true
            let oWonRightVertical = topRightValue == true && centerRightValue == true && bottomRightValue == true
            
           guard oWonTopHorizontal || oWonCenterHorizontal || oWonBottomHorizontal ||
                    oWonDiagonalLeft || oWonDiagonalRight ||
                    oWonLeftVertical || oWonCenterVertical || oWonRightVertical else {
               return
           }
           print("o won")
        }
        
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
        let material = SimpleMaterial(color: .clear.withAlphaComponent(0.0000001), isMetallic: false)
        
        let tapEntity = ModelEntity(mesh: rectangle, materials: [material])
        tapEntity.generateCollisionShapes(recursive: true)
        tapEntity.name = postion.rawValue
        tapEntity.position = [xPos, 0, zPos]
        anchor.addChild(tapEntity)
    }
}
