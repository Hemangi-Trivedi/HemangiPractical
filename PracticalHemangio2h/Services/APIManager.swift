//
//  APIManager.swift
//  PracticalHemangio2h
//
//  Created by Shubham's Macbook on 03/02/24.
//

import Alamofire
import Foundation

class APIManager {
    static let shared = APIManager()
    
    private init() {}
    

    func fetchDataFromAPI(completion: @escaping ([Apidata]?, Error?) -> Void) {
        let urlString = "https://pixabay.com/api/?key=6535859-9848eef233ce93e8bfb33e5a6&q=wallpaper"
        
        AF.request(urlString).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                guard let json = value as? [String: Any] else {
                    completion(nil, NSError(domain: "ParsingError", code: 0, userInfo: nil))
                    return
                }
                if let hits = json["hits"] as? [[String: Any]] {
                    let images = hits.map { Apidata(dict: $0) }
                    completion(images, nil)
                } else {
                    completion(nil, NSError(domain: "ParsingError", code: 0, userInfo: nil))
                }
            case .failure(let error):
                let errorMessage = error.localizedDescription
                let alertController = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(okAction)
                UIApplication.shared.keyWindow?.rootViewController?.present(alertController, animated: true, completion: nil)
                
                completion(nil, error)
            }
        }
    }


//    func fetchDataFromAPI(completion: @escaping ([Apidata]?, Error?) -> Void) {
//        let urlString = "https://pixabay.com/api/?key=6535859-9848eef233ce93e8bfb33e5a6&q=wallpaper"
//        guard let url = URL(string: urlString) else {
//            completion(nil, NSError(domain: "InvalidURL", code: 0, userInfo: nil))
//            return
//        }
//
//        URLSession.shared.dataTask(with: url) { data, response, error in
//            if let error = error {
//                completion(nil, error)
//                return
//            }
//
//            guard let data = data else {
//                completion(nil, NSError(domain: "NoData", code: 0, userInfo: nil))
//                return
//            }
//
//            do {
//                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
//                if let hits = json?["hits"] as? [[String: Any]] {
//                    let images = hits.map { Apidata(dict: $0) }
//                    completion(images, nil)
//                } else {
//                    completion(nil, NSError(domain: "ParsingError", code: 0, userInfo: nil))
//                }
//            } catch {
//                completion(nil, error)
//            }
//        }.resume()
//    }
}
