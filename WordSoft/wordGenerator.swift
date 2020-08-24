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
    

    init() {
        if let inputList = wordGenerator.loadData(fileName: "wordList.txt") {
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
        let indexList = defaults.object(forKey: "indexSet") as? [Int] ?? [Int]()
        //print("IndexList: ")
        if !indexList.isEmpty {
            indexSet = Set(indexList)
        }
        freqList = defaults.object(forKey: "freqList") as? [Int] ?? frequencies
        
        lastSampledIndex = defaults.integer(forKey: "lastSampledIndex")
        history = defaults.object(forKey: "history") as? [Int] ?? [Int]()
        numSampled = defaults.integer(forKey: "numSampled")
        navOffset = defaults.integer(forKey: "navOffset")

        // Maintaining: Test freqList flaws
        //fixFreqList()
        //assert(!freqListIsFlaw())
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
        
        /*
        for i in history {
            //print(freqList[i-1] + caseTesed[i-1])
            //print(frequencies[i-1])
            if freqList[i-1] + caseTesed[i-1] < frequencies[i-1] {
                print("some word will be tested less than supposed amount:")
                print(wordList[i-1])
                print(freqList[i-1])
                print(caseTesed[i-1])
                print(frequencies[i-1])
                return true
            }
        }
         */
        
        for wordID in indexSet {
            if !(freqList[wordID-1] > 0) {
                
                print("Some word haven't tested will not be tested")
                print(wordList[wordID-1])
                return true
            }
        }
        
        return numRawWords - numSampled != remainingWordNum
    }
    
    func fixFreqList() {
        
        numSampled = 2200
        
        freqList = Array(repeating: 0, count: wordList.count)
        // Re add every thing that must reappear
        print("indexset size")
        print(indexSet.count)
        for i in indexSet {
            
            if i < 1 || i > freqList.count {
                indexSet.remove(i)
                print("removed illegal index from indexSet")
                print(i)
                break
            }
            if freqList[i-1] == 0 {
                freqList[i-1] += 1
            }
        }
        
        print("First stage fix")
        print(freqListIsFlaw())
        

        let remainingTest: Int = numRawWords - numSampled - indexSet.count
        print("remainingTest")
        print(remainingTest)
        
        var j = 0
        var last_j = j
        for _ in 1...remainingTest {
            while !(freqList[j] < frequencies[j]) {
                j += 1
                if j >= freqList.count {
                    j = 0
                }
                if j == last_j {
                    print("cannot balance")
                    break
                }
                
            }
            last_j = j
            freqList[j] += 1
                
        }
        let sum = freqList.reduce(0, +)
        print(sum)
        print(remainingTest)
        assert(sum == numRawWords - numSampled)
        return
        
        /*
        // Assume every time user hit pass button
        print("Reducing tested words from list")
        for i in history {
            //caseTesed[i-1] += 1
            if freqList[i-1] > 0 {
                freqList[i-1] -= 1
            }
        }
        
        print("Second stage fix")
        print(freqListIsFlaw())
        

        var caseTesed = Array(repeating: 0, count: wordList.count)
        for i in history {
            caseTesed[i-1] += 1
        }
        
        // Re add every thing that must reappear
        print("indexset size")
        print(indexSet.count)
        for i in indexSet {
            
            if i < 1 || i > freqList.count {
                indexSet.remove(i)
                print("removed illegal index from indexSet")
                print(i)
                break
            }
            if freqList[i-1] == 0 {
                freqList[i-1] += 1
            }
        }
        
        print("First stage fix")
        print(freqListIsFlaw())
        
        

        
        
        
        var totalReduce:Int = 0
        for i in 1...freqList.count {
            if freqList[i-1] > frequencies[i-1] {
                let amt = freqList[i-1] - frequencies[i-1]
                totalReduce += amt
                
                freqList[i-1] = frequencies[i-1]
                
            }
        }
        print("Third stage fix")
        print("totalReduce")
        print(totalReduce)
        
        print(freqListIsFlaw())
        
       
        
        
        let remainingWordNum = freqList.reduce(0, +)
        print("remainingWordNum")
        print(remainingWordNum)
        
        // Evenly readd missing samples to ensure total tests number compatible
        let remainingTest = numRawWords - numSampled
        print("remainingTest")
        print(remainingTest)

        if remainingWordNum > remainingTest {
            numSampled = numRawWords - remainingWordNum
            
            print("adjust test amount")
            //print(freqListIsFlaw())
                   
            //print("saving fix change")
            //saveProgress()
        }
        else if remainingWordNum != remainingTest {
            assert(remainingWordNum < remainingTest)
           
            let diff: Int = remainingTest - remainingWordNum
            print("diff")
            print(diff)
            
            var j = 0
            var last_j = j
            for _ in 1...diff {
                while !(freqList[j] < frequencies[j]) {
                    j += 1
                    if j >= freqList.count {
                        j = 0
                    }
                    if j == last_j {
                        print("cannot balance")
                        break
                    }
                    
                }
                last_j = j
                freqList[j] += 1
                    
            }
            assert(freqList.reduce(0, +) == remainingTest)
        }
        
        print("Fourth stage fix")
        print(freqListIsFlaw())
        
        // Get available spaces
        var totalAmt = 0
        for i in history {
            //print(freqList[i-1] + caseTesed[i-1])
            //print(frequencies[i-1])
            if freqList[i-1] + caseTesed[i-1] < frequencies[i-1] {
                let amt = frequencies[i-1] - (freqList[i-1] + caseTesed[i-1])
                assert(amt > 0)
                assert(freqList[i-1] >= 0)
                freqList[i-1] += amt
                totalAmt += amt
            }
        }
        print("totalAmt")
        print(totalAmt)
        
        var j = 0
        var last_j = j
        for _ in 1...totalAmt {
            while !(freqList[j] + caseTesed[j] > frequencies[j] && !(freqList[j] == 1 && indexSet.contains(j))) {
                j += 1
                if j >= freqList.count {
                    j = 0
                }
                if j == last_j {
                    print("cannot balance total amt")
                    break
                }
            }
            last_j = j
            if freqList[j] > 0 {
                freqList[j] -= 1
            }
            assert(freqList[j] >= 0)
        }
        
        print("Fix stage 5: rebalancing ")
        //numSampled = numRawWords - freqList.reduce(0, +)
        print("fix complete")
        
        print(freqListIsFlaw())
        //print(freqList)
        print("saving fix")
        saveProgress()
        */
        
    }
    
    func saveProgress() {
        //print("In saveProgress")
        let defaults = UserDefaults.standard
        defaults.set(Array(indexSet), forKey: "indexSet")

        defaults.set(Array(freqList), forKey: "freqList")
        
        defaults.set(lastSampledIndex, forKey: "lastSampledIndex")
        //print(lastSampledIndex)
        //print(history)
        defaults.set(history, forKey: "history")
        defaults.set(numSampled, forKey: "numSampled")
        defaults.set(navOffset, forKey: "navOffset")
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
