//
//  DatabaseManager.swift
//  PracticalHemangio2h
//
//  Created by Shubham's Macbook on 02/02/24.
//

import Foundation
import FMDB

final class DatabaseManager {
    static let databaseFileName = "GallaryImage.db"
    static var database:FMDatabase!
    static let shared: DatabaseManager = {
        let instance = DatabaseManager()
        return instance
    }()
    
    
    func createDatabse()  {
        
        let bundlePath = Bundle.main.path(forResource: "GallaryImage", ofType: ".db")
        print(bundlePath ?? "", "\n") //prints the correct path
        let destPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let fileManager = FileManager.default
        let fullDestPath = NSURL(fileURLWithPath: destPath).appendingPathComponent("GallaryImage.db")
        let fullDestPathString = fullDestPath!.path
        
        if fileManager.fileExists(atPath: fullDestPathString) {
            print("File is available")
            DatabaseManager.database = FMDatabase(path: fullDestPathString)
                    openDataBase()
            print(fullDestPathString)
        }
        else{
            do{
                try fileManager.copyItem(atPath: bundlePath!, toPath: fullDestPathString)
                if fileManager.fileExists(atPath: fullDestPathString) {
                    DatabaseManager.database = FMDatabase(path: fullDestPathString)
                    openDataBase()
                    
                    print("File is copy")
                }else {
                    print("File is not copy")
                }
            }catch{
                print("\n")
                print(error)
            }
        }
    }
    
    
    func openDataBase() {
        if DatabaseManager.database != nil {
            DatabaseManager.database.open()
            //deleteTran()
        }else {
            DatabaseManager.shared.createDatabse()
        }
    }
    
    func closeDataBase() {
        if DatabaseManager.database != nil {
            DatabaseManager.database.close()
        }else {
            
        }
    }
    
    func SaveImageDetails(_ Imagedata: Apidata) -> Bool {
        DatabaseManager.database.open()
        let isSave = DatabaseManager.database.executeUpdate("INSERT INTO GalleryData (Image) VALUES(?)", withArgumentsIn:[Imagedata.largeImageURL])
        
        DatabaseManager.database.close()
        
        return isSave
    }
    
    func getGalleryData(completion: @escaping ([Apidata]?) -> Void) {
        guard let database = DatabaseManager.database else {
            print("Database is nil")
            completion(nil)
            return
        }

        guard database.open() else {
            print("Failed to open database")
            completion(nil)
            return
        }

        var galleryData: [Apidata] = []

        do {
            let resultSet = try database.executeQuery("SELECT * FROM GalleryData", values: nil)
            
            while resultSet.next() {
                let imageURL = resultSet.string(forColumn: "Image") ?? ""
                let data = ["largeImageURL": imageURL]
                let imageData = Apidata(dict: data)
                galleryData.append(imageData)
            }

            completion(galleryData)
        } catch {
            print("Error retrieving gallery data: \(error.localizedDescription)")
            completion(nil)
        }
        
        database.close()
    }



    func deleteAllDataFromGalleryData() {
           DatabaseManager.database.open()
           
           do {
               try DatabaseManager.database.executeUpdate("DELETE FROM GalleryData", values: nil)
           } catch {
               print("Error deleting data from GalleryData: \(error.localizedDescription)")
           }
           
           DatabaseManager.database.close()
       }

    func hasMoreThan20Entries(completion: @escaping (Bool?) -> Void) {
        DatabaseManager.database.open()

        do {
            let resultSet = try DatabaseManager.database.executeQuery("SELECT COUNT(*) FROM GalleryData", values: nil)
            guard resultSet.next() else {
                completion(nil)
                return
            }
            let count = resultSet.long(forColumnIndex: 0)
            completion(count > 20)
        } catch {
            print("Error fetching count: \(error)")
            completion(nil)
        }
        
        DatabaseManager.database.close()
    }

}

