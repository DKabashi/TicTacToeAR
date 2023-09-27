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
        viewModel.addBoardEntity(in: scene)
    }
    
    @objc private func viewTapped(_ recognizer: UITapGestureRecognizer) {
        let tapLocation = recognizer.location(in: self)
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

