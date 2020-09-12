//
//  wordGenerator.swift
//  WordSoft
//
//  Created by 张光正 on 7/27/20.
//  Copyright © 2020 张光正. All rights reserved.
//

import UIKit

class wordGenerator{
    
    var numRawWords = 0
    var wordList = [String]()
    var frequencies = [Int]()   // Static frequency list for reference
    var freqList = [Int]()      // Dynamic frequency list
    var indexMap = [String:Int]()
    var indexSet: Set<Int>
    //var wrongIndexSet: Set<Int> = Set<Int>()
    var lastSampledIndex: Int = -1
    var history = [Int]()   // History of word test in term of index
    var numSampled: Int = 0
    var navOffset: Int = 0
    
    let wordfilename: String = "wordList3.txt"

    init() {
        
        if let inputList = wordGenerator.loadData(fileName: wordfilename) {
            numRawWords = inputList.count
            let result = wordGenerator.handleData(inputList: inputList)
            wordList = result.uniqueWords
            frequencies = result.frequencies
            freqList = frequencies
            indexMap = result.wordIndices
        } else {
            fatalError("Cannot load data")
        }
        
        // Read saved values if any
        let defaults = UserDefaults.standard
        //wordList = ["word1", "word2", "word3", "word4", "word5"]
        //indexSet = Set<Int>(0...wordList.count-1)
        indexSet = Set<Int>(indexMap.values)
        //var indexList = [Int]()
        if defaults.object(forKey: "indexSet" + wordfilename) != nil {
            let indexList = defaults.object(forKey: "indexSet" + wordfilename) as! [Int]
            indexSet = Set(indexList)
        }
        //let indexList = defaults.object(forKey: "indexSet" + wordfilename) as? [Int] ?? [Int]()
        //print("IndexSet: ")
        //print(indexSet)
        //indexSet = Set(indexList)
        
        freqList = defaults.object(forKey: "freqList" + wordfilename) as? [Int] ?? frequencies
        
        lastSampledIndex = defaults.integer(forKey: "lastSampledIndex" + wordfilename)
        history = defaults.object(forKey: "history" + wordfilename) as? [Int] ?? [Int]()
        numSampled = defaults.integer(forKey: "numSampled" + wordfilename)
        navOffset = defaults.integer(forKey: "navOffset" + wordfilename)

    }
    
    static func loadData(fileName: String) -> [String]? {
        // Read Disk to load word list data
        let nameComp = fileName.components(separatedBy: ".")
        if (nameComp.count != 2) {
            print("Illegal Filename Format")
            return nil
        }
        if let filepath = Bundle.main.path(forResource: nameComp[0], ofType: nameComp[1]) {
            do {
                let contents = try String(contentsOfFile: filepath)
                var inputWords = contents.components(separatedBy: "\n")
                if inputWords[inputWords.count-1].isEmpty { // Remove empty element at tail
                    inputWords.removeLast()
                }
                //let inputWords = contents.split { $0.isNewline }
                //print(inputWords)
                return inputWords
            } catch {
                // contents could not be loaded
                print("Cannot cast content to string list")
            }
        }
        else {
            print("Path not found")
        }
        return nil
    }
    
    static func handleData(inputList: [String]) -> (wordIndices:[String:Int], uniqueWords:[String], frequencies:[Int]) {
        
        var wordIndex: [String:Int] = [:]
        //var indexList = [Int]()
        var uniqueWordList = [String]()
        var freqList = [Int]()
        var currIndex: Int = 0
        
        for word in inputList {
            
            if wordIndex[word] != nil {
                
                freqList[wordIndex[word]!-1] += 1
            }
            else {
                currIndex += 1
                wordIndex[word] = currIndex
                uniqueWordList.append(word)
                
                freqList.append(1)
                /*if currIndex == 2138 {
                    print("In handleData")
                    print(freqList.count)
                }*/
            }
        }
        //print(wordIndex)
        //print("In handleData End")
        //print(uniqueWordList.count)
        //print(freqList)
        return (wordIndex, uniqueWordList, freqList)
    }
    
    func freqListIsFlaw() -> Bool {
        
        
        let frequenciesTotal = frequencies.reduce(0, +)
        //print(frequenciesTotal)
        //print(numRawWords)
        if frequenciesTotal != numRawWords {
            print("Static data not compatible")
            return true
        }
        
        var caseTesed = Array(repeating: 0, count: wordList.count)
        for i in history {
            caseTesed[i-1] += 1
        }
        
        let remainingWordNum = freqList.reduce(0, +)
        /*print("total remaining tests")
        print(remainingWordNum)
        print("true remaing tests")
        print(numRawWords - numSampled)*/
        
        
        for wordID in indexSet {
            if !(freqList[wordID-1] > 0) {
                
                print("Some word haven't tested will not be tested")
                print(wordList[wordID-1])
                return true
            }
        }
        
        return numRawWords - numSampled != remainingWordNum
    }
    
    func saveProgress() {
        //print("In saveProgress")
        let defaults = UserDefaults.standard
        defaults.set(Array(indexSet), forKey: "indexSet" + wordfilename)

        defaults.set(Array(freqList), forKey: "freqList" + wordfilename)
        
        defaults.set(lastSampledIndex, forKey: "lastSampledIndex" + wordfilename)
        //print(lastSampledIndex)
        //print(history)
        defaults.set(history, forKey: "history" + wordfilename)
        defaults.set(numSampled, forKey: "numSampled" + wordfilename)
        defaults.set(navOffset, forKey: "navOffset" + wordfilename)
    }

    
    func getNumSampled() -> Int {
        return numSampled
    }
    
    func getNumTotal() -> Int {
        return numRawWords
    }
    
    func sampleWord() -> String {
        
        if !indexSet.isEmpty {
            //print("Sampling new staff")
            // Get a random index and remove it from list
            lastSampledIndex = indexSet.randomElement()!
            //print(lastSampledIndex)
            if lastSampledIndex > 0 && lastSampledIndex <= wordList.count {
                navOffset = 0
                
                //print(lastSampledIndex)
                history.append(lastSampledIndex)
                //print(history)
                
            }
            else {  // Index Error occuring
                //print("Error index: ")
                //print(lastSampledIndex)
                fatalError()
            }
        }
        else {  // Handle out-of-sample: Repeat giving the last sample
            //print("getting last sample")
            //print(lastSampledIndex)
            if lastSampledIndex > 0 && lastSampledIndex <= wordList.count {
                // No more sample in source, return the last sampled element.
                navOffset = 0
            }
            else {  // Source empty at beginning
                fatalError()
            }
        }
        saveProgress()
        return wordList[lastSampledIndex-1]
        
    }
    
    func unreplaceWord() {
        print(indexSet.count)
        //print(indexSet)
        if indexSet.isEmpty {   // When source is empty
           return
        }
        //print("taxing frequnecy:")
        //print(freqList[indexMap["taxing"]!-1])
        /*if freqList[indexMap["taxing"]!-1] == 0 {
            print("taxing frequency is zero")
        }*/
        //print(wordList[lastSampledIndex-1])
        //print(lastSampledIndex)
        //print(freqList[lastSampledIndex-1])
        //print(freqList)
        if freqList[lastSampledIndex-1] == 1 {
            let removed: Int = indexSet.remove(lastSampledIndex) ?? -1
            if removed != lastSampledIndex { // Last sampled index not exist in source
                fatalError()
            }
            freqList[lastSampledIndex-1] -= 1
        }
        else {  // To maintain non-uniform multinomial distribution
            //print("Reducing frequency")
            freqList[lastSampledIndex-1] -= 1
            //print(freqList[lastSampledIndex-1])
        }
        
        numSampled += 1 // Record number of sample reduced
        saveProgress()
    }
    
    func lookBefore() -> String {
        //print(history)
        //print(navOffset)
        if navOffset < history.count-1 {
            //print(navOffset)
            navOffset += 1
            saveProgress()
        }
        return wordList[history[history.count-1 - navOffset]-1]
    }
    
    func lookAfter() -> String {
        //print(history)
        //print(navOffset)
        if navOffset > 0 {
            navOffset -= 1
            saveProgress()
        }
        return wordList[history[history.count-1 - navOffset]-1]
    }
    
    func setNavPos(newpos: Int) {
        if newpos >= 0 && newpos < history.count {
            navOffset = history.count-1 - newpos
            saveProgress()
        }
    }
    
    func resetAll() {
        freqList = frequencies
        indexSet = Set<Int>(indexMap.values)
        //print(indexSet)
        lastSampledIndex = -1
        history = [Int]()   // History of word test in term of index
        numSampled = 0
        navOffset = 0
        
        saveProgress()
    }
    
    func getNavPos() -> Int {
        return navOffset
    }
    
    func getCurrNavWord()->String {
        //print(history)
        //print(navOffset)
        return wordList[history[history.count-1 - navOffset]-1]
    }
    
    func getHistoryList() -> [String] {
        var wordHist = [String]()
        for i in history {
            assert(i > 0 && i <= wordList.count)
            wordHist.append(wordList[i-1])
        }
        return wordHist
    }
    
    func isRunning() -> Bool {
        return lastSampledIndex > 0
    }
    
}
