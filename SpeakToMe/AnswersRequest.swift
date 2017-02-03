//
//  AnswersRequest.swift
//  SpeakToMe
//
//  Created by Rafael Alencar on 03/02/17.
//  Copyright © 2017 Henry Mason. All rights reserved.
//

import Foundation

struct AnswersRequest {
    
    private let session: URLSession
    private let baseURLString = "http://soulvox.mybluemix.net/post"
    
    init() {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 30
        
        let session = URLSession(configuration: configuration)
        
        self.session = session
    }
    
    func getAnswers(for question: String, completionHandler: @escaping ([String]) -> Void) {
        
        guard let url = URL(string: baseURLString) else {
            completionHandler([])
            return
        }
        
        let dict = ["txt": question]
        let json: Data
        
        do {
            json = try JSONSerialization.data(withJSONObject: dict, options: [])
        }
        catch {
            completionHandler([])
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = json
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = session.dataTask(with: request) { (data, response, error) in
            guard error == nil else {
                print("Failed to get answers with error: \(error).")
                
                DispatchQueue.main.async {
                    completionHandler([])
                }
                
                return
            }
            
            guard let jsonData = data else {
                print("Failed to valid data.")
                
                DispatchQueue.main.async {
                    completionHandler([])
                }
                
                return
            }
            
            guard let _answers = try? JSONSerialization.jsonObject(with: jsonData, options: [.allowFragments]) as? Array<String> else {
                print("Failed to get answers in a valid format.")
                
                DispatchQueue.main.async {
                    completionHandler([])
                }
                
                return
            }
            
            guard let answers = _answers else {
                print("Failed to get answers.")
                
                DispatchQueue.main.async {
                    completionHandler([])
                }
                
                return
            }
            
            DispatchQueue.main.async {
                completionHandler(answers)
            }
            
            return
        }
        
        task.resume()
    }
}
