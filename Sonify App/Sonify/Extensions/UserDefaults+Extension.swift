//
//  UserDefaults+Extension.swift
//  Sonify
//
//  Created by Meghan Blyth on 05/08/2021.
//
//Fetching the sonified pictures from the database. 
import Foundation

extension UserDefaults {
    private enum UserDefaultsKeys: String {
        case sonifiedAudioList
    }
    
    var sonifiedAudioList: [SonifiedData] {
        get {
            if let data = object(forKey: UserDefaultsKeys.sonifiedAudioList.rawValue) as? Data {
                let list = try? JSONDecoder().decode([SonifiedData].self, from: data)
                return list ?? []
            }
            return []
        }
        
        set {
            let data = try? JSONEncoder().encode(newValue)
            setValue(data, forKey: UserDefaultsKeys.sonifiedAudioList.rawValue)
        }
    }
}
