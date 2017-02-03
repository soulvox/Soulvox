//
//  AnswersViewController.swift
//  SpeakToMe
//
//  Created by Rafael Alencar on 03/02/17.
//  Copyright © 2017 Henry Mason. All rights reserved.
//

import UIKit
import AVFoundation

final class AnswersViewController: UITableViewController, AVSpeechSynthesizerDelegate {
    
    private let answers: [String]
    private let synthesizer = AVSpeechSynthesizer()
    
    private var timer: Timer?
    
    private var selectedRow: Int = -1
    
    private var gesture: UITapGestureRecognizer?
    
    private static let reuseIdentifier = "answerCell"
    
    init(answers: [String]) {
        self.answers = answers
        
        super.init(nibName: nil, bundle: nil)
        
        synthesizer.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(colorLiteralRed: 0.33, green: 0.28, blue: 0.25, alpha: 1.0)
        
        tableView.allowsSelection = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: AnswersViewController.reuseIdentifier)
        
        guard answers.count > 0 else { return }
        
        let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0))
        cell?.isHighlighted = true
        
        gesture = UITapGestureRecognizer(target: self, action: #selector(AnswersViewController.tap))
        view.addGestureRecognizer(gesture!)
    }
    
    @objc private func tap() {
        timer?.invalidate()
        
        let text = self.answers[self.selectedRow]
        
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate
        utterance.voice = AVSpeechSynthesisVoice(language: "pt-BR")
        
        synthesizer.speak(utterance)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard answers.count > 0 else { return }
        
        setTimer()
    }
    
    private func setTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true, block: { (timer) in
            if self.selectedRow + 1 > self.answers.count - 1 {
                self.selectedRow = 0
            } else{
                self.selectedRow += 1
            }
            
            let previousRow = self.selectedRow == 0 ? self.answers.count - 1 : self.selectedRow - 1
            
            let previousCell = self.tableView.cellForRow(at: IndexPath(row: previousRow, section: 0))
            let currentCell = self.tableView.cellForRow(at: IndexPath(row: self.selectedRow, section: 0))
            
            previousCell?.textLabel?.textColor = UIColor.white
            currentCell?.textLabel?.textColor = UIColor(colorLiteralRed: 0.33, green: 0.28, blue: 0.25, alpha: 1.0)
            
            previousCell?.isHighlighted = false
            currentCell?.isHighlighted = true
        })
        
        timer?.fire()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        timer?.invalidate()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.answers.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: AnswersViewController.reuseIdentifier, for: indexPath)
        
        cell.textLabel?.text = self.answers[indexPath.row]
        cell.backgroundColor = UIColor(colorLiteralRed: 0.33, green: 0.28, blue: 0.25, alpha: 1.0)
        cell.textLabel?.textColor = UIColor.white
        
        return cell
    }
    
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let text = self.answers[indexPath.row]
//        
//        let utterance = AVSpeechUtterance(string: text)
//        utterance.rate = AVSpeechUtteranceDefaultSpeechRate
//        utterance.voice = AVSpeechSynthesisVoice(language: "pt-BR")
//        
//        synthesizer.speak(utterance)
//    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        print("Starting")
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        setTimer()
    }
}
