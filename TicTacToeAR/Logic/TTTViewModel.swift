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
import SwiftUI

class TTTViewModel: ObservableObject {
    private var boardEntity: ModelEntity!
    private var isXTurn = true
    private var boardValues = [XOPosition: XOModel]()
    private var cancellables: Set<AnyCancellable> = []

    var gameAnchor: AnchorEntity?
    var restartGameAction: (() -> Void)?
    @Published var isGameOver = false
    
    func addBoardEntity(in scene: RealityKit.Scene, arView: ARView) {
        let anchor = AnchorEntity(plane: .horizontal, minimumBounds: [0.2, 0.2])
        anchor.setScale(SIMD3<Float>(0.002, 0.002, 0.002), relativeTo: anchor)
        
        self.gameAnchor = anchor
        ModelEntity.loadModelAsync(named: TTTAsset.board.rawValue)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let err): print(err.localizedDescription)
                default: return
                }
            }, receiveValue: { [weak self] entity in
                guard let self = self else { return }
                entity.name = TTTAsset.board.rawValue
                entity.generateCollisionShapes(recursive: true)
                anchor.addChild(entity)
                
                for position in XOPosition.allCases {
                    self.generateTapEntity(in: position, anchor: anchor)
                }
                
                scene.addAnchor(anchor)
                
                arView.installGestures(.all, for: entity)
                self.boardEntity = entity
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
                self.boardValues[postion] = XOModel(isX: self.isXTurn, entity: xoEntity)
                
                self.checkGameStatus()
                self.isXTurn.toggle()
            })
            .store(in: &cancellables)
    }
    
    func restartGame() {
        isXTurn = true
        boardValues = [:]
        withAnimation {
            isGameOver = false
        }
        restartGameAction?()
    }
    
    private func animateEntities(positions: [XOPosition]) {
        for position in positions {
            guard let xoEntity = boardValues[position]?.entity else { continue }
            var translation = xoEntity.transform
            translation.translation = SIMD3(SCNVector3(0, self.isXTurn ? 14 : 18, 0))
            xoEntity.move(to: translation, relativeTo: xoEntity.parent, duration: 0.3, timingFunction: .easeInOut)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                var rotation = xoEntity.transform
                rotation.rotation = simd_quatf(angle: .pi/2, axis: [1,0,0])
                xoEntity.move(to: rotation, relativeTo: xoEntity.parent, duration: 0.3, timingFunction: .easeInOut)
            }
        }
        
        withAnimation {
            isGameOver = true
        }
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
            let xWonTopHorizontal = topLeftValue?.isX == true && topCenterValue?.isX == true && topRightValue?.isX == true
            if xWonTopHorizontal {
                animateEntities(positions: [.topLeft, .topCenter, .topRight])
            }
            
            let xWonCenterHorizontal = centerLeftValue?.isX == true && centerCenterValue?.isX == true && centerRightValue?.isX == true
            if xWonCenterHorizontal {
                animateEntities(positions: [.centerLeft, .centerCenter, .centerRight])
            }
            
            let xWonBottomHorizontal = bottomLeftValue?.isX == true && bottomCenterValue?.isX == true && bottomRightValue?.isX == true
            if xWonBottomHorizontal {
                animateEntities(positions: [.bottomLeft, .bottomCenter, .bottomRight])
            }
            
            let xWonDiagonalLeft = topLeftValue?.isX == true && centerCenterValue?.isX == true && bottomRightValue?.isX == true
            if xWonDiagonalLeft {
                animateEntities(positions: [.topLeft, .centerCenter, .bottomRight])
            }
            
            let xWonDiagonalRight = topRightValue?.isX == true && centerCenterValue?.isX == true && bottomLeftValue?.isX == true
            if xWonDiagonalRight {
                animateEntities(positions: [.topRight, .centerCenter, .bottomLeft])
            }
            
            let xWonLeftVertical = topLeftValue?.isX == true && centerLeftValue?.isX == true && bottomLeftValue?.isX == true
            if xWonLeftVertical {
                animateEntities(positions: [.topLeft, .centerLeft, .bottomLeft])
            }
            
            let xWonCenterVertical = topCenterValue?.isX == true && centerCenterValue?.isX == true && bottomCenterValue?.isX == true
            if xWonCenterVertical {
                animateEntities(positions: [.topCenter, .centerCenter, .bottomCenter])
            }
            
            let xWonRightVertical = topRightValue?.isX == true && centerRightValue?.isX == true && bottomRightValue?.isX == true
            if xWonRightVertical {
                animateEntities(positions: [.topRight, .centerRight, .bottomRight])
            }
        } else {
            let oWonTopHorizontal = topLeftValue?.isX == false && topCenterValue?.isX == false && topRightValue?.isX == false
            if oWonTopHorizontal {
                animateEntities(positions: [.topLeft, .topCenter, .topRight])
            }
            
            let oWonCenterHorizontal = centerLeftValue?.isX == false && centerCenterValue?.isX == false && centerRightValue?.isX == false
            if oWonCenterHorizontal {
                animateEntities(positions: [.centerLeft, .centerCenter, .centerRight])
            }
            
            let oWonBottomHorizontal = bottomLeftValue?.isX == false && bottomCenterValue?.isX == false && bottomRightValue?.isX == false
            if oWonBottomHorizontal {
                animateEntities(positions: [.bottomLeft, .bottomCenter, .bottomRight])
            }
            
            
            let oWonDiagonalLeft = topLeftValue?.isX == false && centerCenterValue?.isX == false && bottomRightValue?.isX == false
            if oWonDiagonalLeft {
                animateEntities(positions: [.topLeft, .centerCenter, .bottomRight])
            }
            
            
            let oWonDiagonalRight = topRightValue?.isX == false && centerCenterValue?.isX == false && bottomLeftValue?.isX == false
            if oWonDiagonalRight {
                animateEntities(positions: [.topRight, .centerCenter, .bottomLeft])
            }
            
            
            let oWonLeftVertical = topLeftValue?.isX == false && centerLeftValue?.isX == false && bottomLeftValue?.isX == false
            if oWonLeftVertical {
                animateEntities(positions: [.topLeft, .centerLeft, .bottomLeft])
            }
            
            
            let oWonCenterVertical = topCenterValue?.isX == false && centerCenterValue?.isX == false && bottomCenterValue?.isX == false
            if oWonCenterVertical {
                animateEntities(positions: [.topCenter, .centerCenter, .bottomCenter])
            }
            
            
            let oWonRightVertical = topRightValue?.isX == false && centerRightValue?.isX == false && bottomRightValue?.isX == false
            if oWonRightVertical {
                animateEntities(positions: [.topRight, .centerRight, .bottomRight])
            }
        }
        
        if boardValues.count == 9 {
            print("game over, no winners")
            return
        }
        
    }
    
    /// Coordinates to position the entity inside the ttt_board.usdz:
    /// x: left: -46, center: 0.274, right: 46,
    /// z: left: -44, center: 3, right: 51
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
