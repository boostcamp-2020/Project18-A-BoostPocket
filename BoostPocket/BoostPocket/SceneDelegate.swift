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
        dataLoader = DataLoader(session: session)
        
        let url = "https://api.exchangeratesapi.io/latest?base=KRW"
        dataLoader?.requestExchangeRate(url: url, completion: { [weak self] (result) in
            guard let self = self, let numberOfCountries = self.persistenceManager.count(request: Country.fetchRequest()) else { return }
            switch result {
            case .success(let data):
                if numberOfCountries <= 0 {
                    print("setup")
                    self.setupCountries(with: data)
                }
//                else {
//                    print("delete all")
//                    self.persistenceManager.deleteAll(request: Country.fetchRequest())
//                }
                
            case .failure(let error):
                print(error.localizedDescription)
            }
            
            DispatchQueue.main.async {
                let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                guard let mainNavigationController = storyboard.instantiateViewController(identifier: "MainNavigationViewController") as? UINavigationController,
                    let travelListVC = mainNavigationController.topViewController as? TravelListViewController else { return }
                travelListVC.countryListViewModel = CountryListViewModel(countryProvider: countryProvider)
                
                self.window?.rootViewController = travelListVC
                self.window?.makeKeyAndVisible()
            }
        })
        
        self.countryProvider = countryProvider
    }
    
    // TODO: - 테스트코드 작성하기
    private func setupCountries(with data: ExchangeRate) {
        let koreaLocale = NSLocale(localeIdentifier: "ko_KR")
        let identifiers = NSLocale.availableLocaleIdentifiers
        let countryDictionary = filterCountries(identifiers, data: data)
        
        countryDictionary.forEach { (countryCode, identifier) in
            let locale = NSLocale(localeIdentifier: identifier)
            if let currencyCode = locale.currencyCode,
                let countryName = koreaLocale.localizedString(forCountryCode: countryCode),
                let exchangeRate = data.rates[currencyCode],
                let flagImage = Flag(countryCode: countryCode)?.originalImage.pngData() {
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?
                let date: Date = dateFormatter.date(from: data.date) ?? Date()
                
                print(date)
                countryProvider?.createCountry(name: countryName, lastUpdated: date, flagImage: flagImage, exchangeRate: exchangeRate, currencyCode: currencyCode)
            }
        }
    }
    
    // TODO: - 테스트코드 작성하기
    private func filterCountries(_ identifiers: [String], data: ExchangeRate) -> [String: String] {
        var filteredIdentifiers: [String: String] = [:]
        
        identifiers.forEach { identifier in
            let locale = NSLocale(localeIdentifier: identifier)
            if let currencyCode = locale.currencyCode,
                let countryCode = locale.countryCode,
                let _ = data.rates[currencyCode],
                let _ = Flag(countryCode: countryCode)?.originalImage.pngData() {
                filteredIdentifiers[countryCode] = identifier
            }
        }
        
        return filteredIdentifiers
    }
    
    func sceneDidDisconnect(_ scene: UIScene) { }
    
    func sceneDidBecomeActive(_ scene: UIScene) { }
    
    func sceneWillResignActive(_ scene: UIScene) { }
    
    func sceneWillEnterForeground(_ scene: UIScene) { }
    
    func sceneDidEnterBackground(_ scene: UIScene) { persistenceManager.saveContext() }
    
}
