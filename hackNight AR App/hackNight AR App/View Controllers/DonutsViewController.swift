//
//  DonutsViewController.swift
//  hackNight AR App
//
//  Created by Berta Devant on 20/02/2018.
//  Copyright © 2018 Berta Devant. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class DonutsViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    private let nodeName = "donut"
    private let fileName = "donut"
    private let fileExtension = "dae"
    private let filePath = "Donuts"

    override func viewDidLoad() {
        super.viewDidLoad()

        sceneView.delegate = self
        sceneView.showsStatistics = true
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        sceneView.session.pause()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let location = touches.first?.location(in: sceneView) else {
            return
        }

        if let nodeExists = sceneView.scene.rootNode.childNode(withName: nodeName, recursively: true) {
            nodeExists.removeFromParentNode()
        }
        addNoteToSceneUsingVector(location: location)
    }

    private func addNoteToSceneUsingVector(location: CGPoint) {
        guard let nodeModel = createSceneNodeForAsset(nodeName, assetPath: "art.scnassets/\(filePath)/\(fileName).\(fileExtension)") else {
            return
        }
        if let hit = getHitResults(location: location, sceneView: sceneView, resultType: [.existingPlaneUsingExtent, .estimatedHorizontalPlane]) {
            let pointTranslation = hit.worldTransform.translation
            nodeModel.position = SCNVector3(pointTranslation.x, pointTranslation.y, pointTranslation.z)
            sceneView.scene.rootNode.addChildNode(nodeModel)
        }
    }

    private func createSceneNodeForAsset(_ assetName: String, assetPath: String) -> SCNNode? {
        guard let paperPlaneScene = SCNScene(named: assetPath) else {
            return nil
        }
        let carNode = paperPlaneScene.rootNode.childNode(withName: assetName, recursively: true)
        return carNode
    }

    private func getHitResults(location: CGPoint, sceneView: ARSCNView, resultType: ARHitTestResult.ResultType) -> ARHitTestResult? {
        let hitResultsFeaturePoints: [ARHitTestResult] = sceneView.hitTest(location, types: resultType)
        if let hit = hitResultsFeaturePoints.first {
            return hit
        }
        return nil
    }

}

extension float4x4 {
    var translation: float3 {
        let translation = self.columns.3
        return float3(translation.x, translation.y, translation.z)
    }
}
