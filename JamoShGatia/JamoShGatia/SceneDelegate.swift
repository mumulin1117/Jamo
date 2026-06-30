//
//  SceneDelegate.swift
//  JamoShGatia
//
//  Created by  on 2026/6/16.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        JamoRiffStageRouter.installOpeningRiffStage(in: window)
    }

    func sceneDidDisconnect(_ scene: UIScene) {
     
    }



}
