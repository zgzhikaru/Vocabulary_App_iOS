//
//  FirstViewController.swift
//  WordSoft
//
//  Created by 张光正 on 7/27/20.
//  Copyright © 2020 张光正. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController {
    @IBOutlet weak var wordDisplay: UILabel!
    @IBOutlet weak var wordCounter: UILabel!
    @IBOutlet weak var historyButton: UIBarButtonItem!
    @IBAction func hitResetButton(_ sender: UIBarButtonItem) {
        gen.resetAll()
        wordDisplay.text = gen.sampleWord()
        wordCounter.text = "Passed: \(gen.getNumSampled())" + "/\(gen.getNumTotal())"
    }
    
    @IBAction func hitCheckButton(_ sender: UIButton) {
        gen.unreplaceWord()
        wordDisplay.text = gen.sampleWord()
        wordCounter.text = "Passed: \(gen.getNumSampled())" + "/\(gen.getNumTotal())"
    }
    @IBAction func hitCrossButton(_ sender: UIButton) {
        wordDisplay.text = gen.sampleWord()
        wordCounter.text = "Passed: \(gen.getNumSampled())" + "/\(gen.getNumTotal())"
    }
    @IBAction func hitBackwardButton(_ sender: UIButton) {
        wordDisplay.text = gen.lookBefore()
    }
    @IBAction func hitForwardButton(_ sender: UIButton) {
        wordDisplay.text = gen.lookAfter()
    }
    
    var gen = wordGenerator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //print("In viewDidLoad")
        //gen = wordGenerator()
        // Do any additional setup after loading the view.
        if !gen.isRunning() {   // First run
            //print("First run")
            wordDisplay.text = gen.sampleWord()
            wordCounter.text = "Passed: \(gen.getNumSampled())" + "/\(gen.getNumTotal())"
        }
        else {
            //print("reopening")
            wordDisplay.text = gen.getCurrNavWord()
            wordCounter.text = "Passed: \(gen.getNumSampled())" + "/\(gen.getNumTotal())"
        }
    }

    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        super.prepare(for: segue, sender: sender)
        
        // Configure the destination view controller only when the save button is pressed.
        let destinationNavigationController = segue.destination as! UINavigationController
        let targetController = destinationNavigationController.topViewController
        
        guard let historyViewController = targetController as? HistoryViewController
            else {
                //print(segue.destination)
                return
            }
        
        let histList = gen.getHistoryList()
        historyViewController.pickerData = histList
        historyViewController.currPos = histList.count - 1 - gen.getNavPos()
    }
    
    // Action
    @IBAction func unwindFromHistory(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? HistoryViewController {
            gen.setNavPos(newpos: sourceViewController.currPos)
            wordDisplay.text = gen.getCurrNavWord()
        }
        else {
            print("Segue return from history goto")
        }
    }
    

}

