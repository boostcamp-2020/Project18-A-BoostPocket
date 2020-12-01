//
//  SceneDelegate.swift
//  BoostPocket
//
//  Created by sihyung you on 2020/11/19.
//  Copyright © 2020 BoostPocket. All rights reserved.
//

import UIKit
import NetworkManager

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    var dataLoader: DataLoader?
    var persistenceManager: PersistenceManagable?
    var countryProvider: CountryProvidable?
    var travelProvider: TravelProvidable?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let _ = (scene as? UIWindowScene) else { return }
        
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: nil)
        let dataLoader = DataLoader(session: session)
        let persistenceManager = PersistenceManager(dataLoader: dataLoader)
        let countryProvider = CountryProvider(persistenceManager: persistenceManager)
        let travelProvider = TravelProvider(persistenceManager: persistenceManager)

        persistenceManager.createCountriesWithAPIRequest()
        
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        guard let mainNavigationController = storyboard.instantiateViewController(identifier: "MainNavigationViewController") as? UINavigationController,
            let travelListVC = mainNavigationController.topViewController as? TravelListViewController else { return }
        
        travelListVC.travelListViewModel = TravelListViewModel(countryProvider: countryProvider, travelProvider: travelProvider)
        
        self.window?.rootViewController = mainNavigationController
        self.window?.makeKeyAndVisible()
    
        self.dataLoader = dataLoader
        self.persistenceManager = persistenceManager
        self.countryProvider = countryProvider
        self.travelProvider = travelProvider
    }
    
    func sceneDidDisconnect(_ scene: UIScene) { }
    
    func sceneDidBecomeActive(_ scene: UIScene) { }
    
    func sceneWillResignActive(_ scene: UIScene) { }
    
    func sceneWillEnterForeground(_ scene: UIScene) { }
    
    func sceneDidEnterBackground(_ scene: UIScene) { self.persistenceManager?.saveContext() }
    
}
