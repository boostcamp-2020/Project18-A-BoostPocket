//
//  SceneDelegate.swift
//  BoostPocket
//
//  Created by sihyung you on 2020/11/19.
//  Copyright © 2020 BoostPocket. All rights reserved.
//

import UIKit
import NetworkManager
import FlagKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var persistenceManager: PersistenceManagable = PersistenceManager()
    var countryProvider: CountryProvidable?
    
    var dataLoader: DataLoader?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        guard let _ = (scene as? UIWindowScene) else { return }
        
        let countryProvider = CountryProvider(persistenceManager: persistenceManager)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: nil)
        self.dataLoader = DataLoader(session: session)
        
        let url = "https://api.exchangeratesapi.io/latest?base=KRW"
        dataLoader?.requestExchangeRate(url: url, completion: { [weak self](result) in
            switch result {
            case .success(let data):
                if let fetchedCountries = self?.countryProvider?.fetchCountries(), fetchedCountries.isEmpty {
                    self?.setupCountries(with: data)
                } else if let countries = self?.countryProvider?.fetchCountries() {
                    countries.forEach { country in
                        self?.persistenceManager.context.delete(country)
                        self?.persistenceManager.saveContext()
                    }
                }
                
            case .failure(let error):
                print(error.localizedDescription)
            }
            
            DispatchQueue.main.async {
                let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                guard let mainNavigationController = storyboard.instantiateViewController(identifier: "MainNavigationViewController") as? UINavigationController,
                      let travelListVC = mainNavigationController.topViewController as? TravelListViewController else { return }
                travelListVC.countryListViewModel = CountryListViewModel(countryProvider: countryProvider)
                
                self?.window?.rootViewController = travelListVC
                self?.window?.makeKeyAndVisible()
            }
        })
        self.countryProvider = countryProvider
    }
    
    private func setupCountries(with data: ExchangeRate) {
        
        let koreaLocale = NSLocale(localeIdentifier: "ko_KR")
        let identifiers = NSLocale.availableLocaleIdentifiers
        identifiers.forEach { identifier in
            let locale = NSLocale(localeIdentifier: identifier)
            if let currencyCode = locale.currencyCode,
               let countryCode = locale.countryCode,
               let countryName = koreaLocale.localizedString(forCountryCode: identifier),
               let exchangeRate = data.rates[currencyCode],
               let flagImage = Flag(countryCode: countryCode)?.originalImage.pngData() {
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?
                let date: Date = dateFormatter.date(from: data.date) ?? Date()
                print(countryProvider?.createCountry(name: countryName, lastUpdated: date, flagImage: flagImage, exchangeRate: exchangeRate, currencyCode: currencyCode))
            }
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.

        // Save changes in the application's managed object context when the application transitions to the background.
        
        // TODO: persistence manager로 대체하기
        // (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }

}
