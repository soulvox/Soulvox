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
    private let baseURLString = "http://soulvox.mybluemix.net/send?txt="
    
    init() {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        
        let session = URLSession(configuration: configuration)
        
        self.session = session
    }
    
    func getAnswers(for question: String, completionHandler: @escaping ([String]) -> Void) {
        
        guard let encodedQuestion = question.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) else {
            completionHandler([])
            return
        }
        
        guard let url = URL(string: baseURLString + encodedQuestion) else {
            completionHandler([])
            return
        }
        
        let task = session.dataTask(with: url) { (data, response, error) in
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
