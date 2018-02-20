//
//  StarWarsViewController.swift
//  hackNight AR App
//
//  Created by Berta Devant on 20/02/2018.
//  Copyright © 2018 Berta Devant. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class StarWarsViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    private let fileName = "model"
    private let fileExtension = "dae"
    private let filePath = "X-Wing"

    override func viewDidLoad() {
        super.viewDidLoad()

        sceneView.delegate = self
        sceneView.showsStatistics = true
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]

        if let scene = SCNScene(named: "art.scnassets/\(filePath)/\(fileName).\(fileExtension)") {
            sceneView.scene = scene
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        sceneView.session.pause()
    }

}
