//
//  StorageManager.swift
//  Messenger
//
//  Created by MRGS on 20.09.2022.
//

import UIKit
import FirebaseStorage


final class StorageManager{
    static let shared = StorageManager()
    
    private let storage = Storage.storage().reference()
    public typealias UploadPictureCompletion = (Result<String, Error>) -> Void
    
    public enum StorageErrors: Error {
        case failedToUpload
        case failedToGetDownloadUrl
    }
    
 
    
    /// Uploads picture to firebase storage and returns completion with url string to download
    public func uploadProfilePicture(with data:Data,fileName:String, completion: @escaping UploadPictureCompletion){
        storage.child("images/\(fileName)").putData(data, metadata: nil, completion: { [weak self] metadata, error in
            guard let strongSelf = self else {
                return
            }
            
            guard error == nil else {
                // failed
                print("failed to upload data to firebase for picture")
                completion(.failure(StorageErrors.failedToUpload))
                return
            }
            
            strongSelf.storage.child("images/\(fileName)").downloadURL(completion: { url, error in
                guard let url = url else {
                    print("Failed to get download url")
                    completion(.failure(StorageErrors.failedToGetDownloadUrl))
                    return
                }
                
                let urlString = url.absoluteString
                print("download url returned: \(urlString)")
                completion(.success(urlString))
            })
        })
        
    }
    
    public func downloadURL(for path: String, completion: @escaping (Result<URL, Error>) -> Void) {
        let reference = storage.child(path)
        reference.downloadURL { url, error in
            guard let url = url,error == nil else{
                completion(.failure(StorageErrors.failedToUpload))
                return
            }
            completion(.success(url))
        }
    }
}
