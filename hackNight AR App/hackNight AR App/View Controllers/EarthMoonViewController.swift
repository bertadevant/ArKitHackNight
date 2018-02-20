//
//  EarthMoonViewController.swift
//  hackNight AR App
//
//  Created by Berta Devant on 20/02/2018.
//  Copyright © 2018 Berta Devant. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class EarthMoonViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    private let nodeName = "banana"
    private let fileName = "banana-small"
    private let fileExtension = "dae"
    private let filePath = ""

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
        guard let earthModel = createSceneNodeForAsset("", assetPath: "art.scnassets/\(filePath)/\(fileName).\(fileExtension)"),
        let moonNode = createSceneNodeForAsset("", assetPath: "art.scnassets/\(filePath)/\(fileName).\(fileExtension)"),
        let lightNode = createSceneNodeForAsset("", assetPath: "art.scnassets/\(filePath)/\(fileName).\(fileExtension)"),
        let planeNode = createSceneNodeForAsset("", assetPath: "art.scnassets/\(filePath)/\(fileName).\(fileExtension)") else {
            return
        }

        if let light: SCNLight = lightNode.light,
            let estimate: ARLightEstimate = sceneView.session.currentFrame?.lightEstimate {
            light.intensity = estimate.ambientIntensity
            light.shadowMode = .deferred
            light.shadowSampleCount = 16
            light.shadowRadius = 24
        }

        if let plane = planeNode.geometry {
            plane.firstMaterial?.writesToDepthBuffer = true
            plane.firstMaterial?.colorBufferWriteMask = []
            plane.firstMaterial?.lightingModel = .constant
        }

        if let hit = getHitResults(location: location, sceneView: sceneView, resultType: [.existingPlaneUsingExtent, .estimatedHorizontalPlane]) {
            let pointTranslation = hit.worldTransform.translation
            let mainNode = getMainNodeFromElementNodes(nodes: [earthModel, moonNode, lightNode, planeNode])
            mainNode.position = SCNVector3(pointTranslation.x, pointTranslation.y, pointTranslation.z)
            sceneView.scene.rootNode.addChildNode(mainNode)
        }
    }

    private func getMainNodeFromElementNodes(nodes: [SCNNode]) -> SCNNode {
        let mainNode = SCNNode()
        nodes.forEach { node in
            mainNode.addChildNode(node)
        }
        return mainNode
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
