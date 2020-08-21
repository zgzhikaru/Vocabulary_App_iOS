//
//  HistoryViewController.swift
//  WordSoft
//
//  Created by 张光正 on 8/5/20.
//  Copyright © 2020 张光正. All rights reserved.
//

import UIKit

class HistoryViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource  {
    
    var pickerData: [String] = [String]()
    var currPos: Int = 0
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    // The data to return fopr the row and component (column) that's being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // This method is triggered whenever the user makes a change to the picker selection.
        // The parameter named row and component represents what was selected.
        currPos = picker.selectedRow(inComponent: 0)
        posDisplay.text = "No. \(currPos+1)" + " of \(pickerData.count)"
    }
    
    
    @IBOutlet weak var posDisplay: UILabel!
    @IBOutlet weak var picker: UIPickerView!
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Connect data:
        self.picker.delegate = self
        self.picker.dataSource = self

        assert(!pickerData.isEmpty && currPos >= 0 && currPos < pickerData.count)
        self.picker.selectRow(currPos, inComponent: 0, animated: false)
        
        posDisplay.text = "No. \(picker.selectedRow(inComponent: 0)+1)" + " of \(pickerData.count)"
    }
    

    
    // MARK: - Navigation
    /*
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    

}
