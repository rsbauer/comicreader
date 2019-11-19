//
//  NetworkProvider.swift
//  ComicReader
//
//  Created by Robert Bauer on 11/13/19.
//  Copyright © 2019 RSB. All rights reserved.
//

import UIKit

public protocol NetworkProviderType {
    func get(url: String, completionBlock: @escaping NetworkCompletionBlock)
    func saveMedia(_ media: [Media], saveHandler: DataStoreProviderSaveHandler?)
    func getMedia(completionHandler: DataStoreProviderCompletionHandler?)
    func getMedia(publicKey: String?, privateKey: String?, completionHandler: DataStoreProviderCompletionHandler?)
    func processResult(_ result: AnyObject) -> MediaResponse
}

public typealias DataResponse = Result<AnyObject, NSError>
public typealias MediaResponse = Result<[Media], NSError>
public typealias NetworkCompletionBlock = (DataResponse) -> Void

public class NetworkProvider: NetworkProviderType {
    private var session = URLSession(configuration: .default)
    private var task: URLSessionDataTask?
    private var privateKey: String?
    private var publicKey: String?
    
    private let dateFormatter = DateFormatter()
    
    
    private enum Constants {
        static let hashDateFormat = "yyyyMMddHHmmss"
        static let marvelPrivateKeyName = "MARVEL_PRIVATE_KEY"
        static let marvelPublicKeyName = "MARVEL_PUBLIC_KEY"
    }
    
    public init() {
        // Public and private keys will be in the bundle.  This is not a secure approach for protecting the keys after
        // the app has shipped.  (A decompiler should be able to pull the plists out and the keys will be in plain text.)
        // This process is in place to keep the public and private keys out of source control.
        if let path = Bundle.main.path(forResource: "Marvel", ofType: "plist") {
            if let plistDictionary = NSDictionary(contentsOfFile: path) {
                privateKey = plistDictionary[Constants.marvelPrivateKeyName] as? String ?? ""
                publicKey = plistDictionary[Constants.marvelPublicKeyName] as? String ?? ""
            }
        }
        
        // Instead of setting the keys in .bash_profile, the keys can be hard coded here, but should not be checked in
        // privateKey = "[your private key here]"
        // publicKey = "[your public key here]"
    }
    
    /// Make a get request using NSURLSession
    ///
    /// - Parameter url: String url to request
    /// - Parameter completionBlock: NetworkCompletionBlock if success or failed
    public func get(url: String, completionBlock: @escaping NetworkCompletionBlock) {
        guard let urlObject = URL(string: url) else {
            return
        }

        // if a task is in flight, cancel it
        task?.cancel()
        
        task = session.dataTask(with: urlObject, completionHandler: { [weak self] (responseData, response, error) in
            guard let strongSelf = self else {
                return
            }
            
            defer {
                strongSelf.task = nil
            }
            
            if let errorExists = error {
                completionBlock(DataResponse.failure(errorExists as NSError))
            }
            
            if let responseExists = response as? HTTPURLResponse,
                responseExists.statusCode == 200,
                let data = responseData {
                completionBlock(DataResponse.success(data as AnyObject))
            }
        })
        
        task?.resume()
    }
    
    private func calculateHash(with ts: String, publicKey: String, privateKey: String) -> String {
        let forHashing = "\(ts)\(privateKey)\(publicKey)"
        return Crypto.MD5(string: forHashing)
    }
}

extension NetworkProvider: DataStoreProviderType {
    /// Save media - this is a network client and does not save back to the web so it returns an error
    ///
    /// - Parameter media: Media array to save
    /// - Parameter saveHandler: DataStoreProviderSaveHandler if success or failed
    public func saveMedia(_ media: [Media], saveHandler: DataStoreProviderSaveHandler?) {
        // At this time, unable to save media back to the web
        saveHandler?(.failure(NSError(domain: "Unable to save media to web.", code: 100, userInfo: nil)))
    }
    
    /// Get media using a given public and private key
    ///
    /// - Parameter publicKey: String public key to use
    /// - Parameter privateKey: String private key  to use
    /// - Parameter completionHandler: DataStoreProviderCompletionHandler if success or failed
    public func getMedia(publicKey: String?, privateKey: String?, completionHandler: DataStoreProviderCompletionHandler?) {
        guard let publicKey = publicKey, let privateKey = privateKey else {
            completionHandler?(.failure(NSError(domain: "\(#function): Failed to load keys", code: 100, userInfo: nil)))
            return
        }
        
        guard publicKey != "" && publicKey != "REMOVED" &&
            privateKey != "" && privateKey != "REMOVED" else {
            completionHandler?(.failure(NSError(domain: "\(#function): Public or private keys were not defined.\n\nPlease define keys MARVEL_PRIVATE_KEY and MARVEL_PUBLIC_KEY in your ~/.bash_profile.", code: 101, userInfo: nil)))
            return
        }
        
        dateFormatter.dateFormat = Constants.hashDateFormat
        let (ts, hash) = generateHash(marvelPublicKey: publicKey, marvelPrivateKey: privateKey)
        let url = "https://gateway.marvel.com:443/v1/public/comics?formatType=comic&dateDescriptor=lastWeek&apikey=\(publicKey)&ts=\(ts)&hash=\(hash)"
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.get(url: url) { (response) in
                switch response {
                case .success(let result):
                    let processResult = strongSelf.processResult(result)

                    switch processResult {
                    case .failure(let error):
                        completionHandler?(.failure(error))
                    case .success(let media):
                        completionHandler?(.success(media))
                    }
                case .failure(let error):
                    completionHandler?(.failure(error))
                }
            }
        }
    }
    
    /// Get media by providing this object's version of the public and private keys
    ///
    /// - Parameter completionHandler: DataStoreProviderCompletionHandler if success or failed
    public func getMedia(completionHandler: DataStoreProviderCompletionHandler?) {
        getMedia(publicKey: publicKey, privateKey: privateKey, completionHandler: completionHandler)
    }
    
    private func generateHash(marvelPublicKey: String, marvelPrivateKey: String) -> (String, String) {
        let now = Date()
        let ts = dateFormatter.string(from: now)
        let hash = calculateHash(with: ts, publicKey: marvelPublicKey, privateKey: marvelPrivateKey)
        
        return (ts, hash)
    }
    
    /// Process the result (should be a Data object).  This method could be private, but making public so it can be
    /// unit tested and verified.
    ///
    /// - Parameter result: AnyObject result (in Data flavor)
    public func processResult(_ result: AnyObject) -> MediaResponse {
        guard let jsonData = result as? Data else {
            let error = NSError(domain: "\(#function): Unable to convert result to Data", code: 100, userInfo: nil)
            return .failure(error)
        }
        
        do {
            let mediaData = try JSONDecoder().decode(MediaData.self, from: jsonData)
            mediaData.saveAttributionText()
            return .success(mediaData.data.results)
        } catch {
            return .failure(error as NSError)
        }
    }

}
