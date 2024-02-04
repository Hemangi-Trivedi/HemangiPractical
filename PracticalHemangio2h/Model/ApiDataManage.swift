//
//  ApiDataManage.swift
//  PracticalHemangio2h
//
//  Created by Shubham's Macbook on 02/02/24.
//

import Foundation




class Apidata: NSObject,Codable {
        
        var largeImageURL: String
    
    init(dict:[String:Any]) {

        largeImageURL = "\(dict["largeImageURL"] ?? "")"
        
    }
}


struct Constants {
    private static let DataImagekey = "DataImagekey"
    static var ImageDataPersistent = UserDefaults.standard.stringArray(forKey: DataImagekey){
        willSet{
            UserDefaults.standard.set(newValue, forKey: DataImagekey)
            UserDefaults.standard.synchronize()
        }
    }
}
