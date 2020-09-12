//
//  ViewController.swift
//  WordSoft
//
//  Created by 张光正 on 8/19/20.
//  Copyright © 2020 张光正. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UISearchBarDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBAction func hitConfirmButton(_ sender: UIBarButtonItem) {
        self.searchBar.endEditing(true)
    }
    @IBAction func hitCancelButton(_ sender: UIBarButtonItem) {
        searchBar.text = nil;
        self.searchBar.endEditing(true)
        
        filteredData = data
        tableView.reloadData()
    }
    
    var data = [String]()
    var wordID = [String:Int]()
    var frequencies = [Int]()

    var filteredData: [String]!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        searchBar.delegate = self
        if let rawData: [String] = wordGenerator.loadData(fileName: "wordList3.txt") {
            let result = wordGenerator.handleData(inputList: rawData)
        
            data = result.uniqueWords
            wordID = result.wordIndices
            frequencies = result.frequencies
        }
        else {
            fatalError("Cannot Read Data in List Mode")
        }
        filteredData = data
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "wordCell", for: indexPath) as UITableViewCell
        cell.textLabel?.text = filteredData[indexPath.row]
        cell.detailTextLabel?.text = "\(frequencies[wordID[filteredData[indexPath.row]]!-1])"
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredData.count
    }

    // This method updates filteredData based on the text in the Search Box
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // When there is no text, filteredData is the same as the original data
        // When user has entered text into the search box
        // Use the filter method to iterate over all items in the data array
        // For each item, return true if the item should be included and false if the
        // item should NOT be included
        filteredData = searchText.isEmpty ? data : data.filter { (item: String) -> Bool in
            // If dataItem matches the searchText, return true to include it
            return item.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
        }
        
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.endEditing(true)
    }
}
