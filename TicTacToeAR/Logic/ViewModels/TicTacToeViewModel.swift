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

class TicTacToeViewModel: ObservableObject {
    private var isXTurn = true
    private var boardValues = [XOPosition: XOModel]()
    private var cancellables: Set<AnyCancellable> = []

    var boardEntity: ModelEntity!
    var gameAnchor: AnchorEntity?
    var restartGameAction: (() -> Void)?
    var removeEditBoardGesturesAction: (() -> Void)?

    @Published var isGameOver = false
    @Published var isTapScreenPresented = true
    @Published var isAdjustBoardPresented = false
    @Published var isLoadingXOEntity = false
    
    func startGame() {
        withAnimation { isAdjustBoardPresented = false }
        XOPosition.allCases.forEach(generateTapEntity)
        removeEditBoardGesturesAction?()
    }
    
    func restartGame() {
        isXTurn = true
        boardValues.removeAll()
        withAnimation {
            isGameOver = false
            isAdjustBoardPresented = false
            isTapScreenPresented = true
        }
        restartGameAction?()
    }
    
    private func endGame() {
        withAnimation { isGameOver = true }
    }
}

// MARK: - ModelEntities
extension TicTacToeViewModel {
    func addBoardEntity(in scene: RealityKit.Scene, arView: ARView) {
        ModelEntity.loadModelAsync(named: AssetReference.board.rawValue)
            .sink(receiveCompletion: { completion in },
                  receiveValue: { [weak self] entity in
                guard let self = self else { return }
                entity.name = AssetReference.board.rawValue
                entity.generateCollisionShapes(recursive: true)
                arView.installGestures(.all, for: entity)
                self.boardEntity = entity
            })
            .store(in: &cancellables)
    }
    
    func addXOEntity(in entity: ModelEntity, at postion: XOPosition) {
        let entityHasNoValue = boardEntity.children.first {
                $0.name == postion.rawValue
        }?.children.allSatisfy { $0.name != AssetReference.x.rawValue && $0.name != AssetReference.o.rawValue } ?? false
        
        guard entityHasNoValue else { return }
        isLoadingXOEntity = true
        ModelEntity.loadModelAsync(named: (isXTurn ? AssetReference.x : AssetReference.o).rawValue)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoadingXOEntity = false
                switch completion {
                case .failure(let err): print(err.localizedDescription)
                default: return
                }
            }, receiveValue: { [weak self] xoEntity in
                guard let self = self else { return }
                xoEntity.name = (self.isXTurn ? AssetReference.x : AssetReference.o).rawValue
                entity.addChild(xoEntity)
                
                self.boardValues[postion] = XOModel(isX: self.isXTurn, entity: xoEntity)
                
                self.checkGameStatus()
                self.isXTurn.toggle()
                self.isLoadingXOEntity = false
            })
            .store(in: &cancellables)
    }
    
    func generateTapEntity(in postion: XOPosition) {        
        var xPos: BoardPosition!
        var zPos: BoardPosition!
        
        switch postion {
        case .topLeft:
            xPos = .xLeft
            zPos = .zLeft
        case .topCenter:
            xPos = .xCenter
            zPos = .zLeft
        case .topRight:
            xPos = .xRight
            zPos = .zLeft
        case .centerLeft:
            xPos = .xLeft
            zPos = .zCenter
        case .centerCenter:
            xPos = .xCenter
            zPos = .zCenter
        case .centerRight:
            xPos = .xRight
            zPos = .zCenter
        case .bottomLeft:
            xPos = .xLeft
            zPos = .zRight
        case .bottomCenter:
            xPos = .xCenter
            zPos = .zRight
        case .bottomRight:
            xPos = .xRight
            zPos = .zRight
        }
        
        let oneThirdBoardSize: Float = 45.66
        let rectangle = MeshResource.generatePlane(width: oneThirdBoardSize, depth: oneThirdBoardSize, cornerRadius: 5)
        let material = UnlitMaterial(color: .clear)
        let tapEntity = ModelEntity(mesh: rectangle, materials: [material])
        tapEntity.generateCollisionShapes(recursive: true)
        tapEntity.name = postion.rawValue
        tapEntity.position = [xPos.rawValue, 0, zPos.rawValue]
        boardEntity.addChild(tapEntity)
    }
}

// MARK: - Animation
extension TicTacToeViewModel {
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
        
        endGame()
    }
}

// MARK: - Game Logic
extension TicTacToeViewModel {
    private func checkGameStatus() {
            let winningCombinations: [[XOPosition]] = [
                [.topLeft, .topCenter, .topRight],
                [.centerLeft, .centerCenter, .centerRight],
                [.bottomLeft, .bottomCenter, .bottomRight],
                [.topLeft, .centerLeft, .bottomLeft],
                [.topCenter, .centerCenter, .bottomCenter],
                [.topRight, .centerRight, .bottomRight],
                [.topLeft, .centerCenter, .bottomRight],
                [.topRight, .centerCenter, .bottomLeft]
            ]
            
            for combination in winningCombinations {
                let values = combination.map { boardValues[$0]?.isX }
                if values.allSatisfy({ $0 == true }) || values.allSatisfy({ $0 == false }) {
                    animateEntities(positions: combination)
                    return
                }
            }
            
            if boardValues.count == 9 {
                endGame()
                return
            }
        }
}
