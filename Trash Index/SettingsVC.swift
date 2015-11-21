//
//  SettingsVC.swift
//  Trash Index
//
//  Created by Dong Liu on 11/15/15.
//  Copyright © 2015 Benjamin. All rights reserved.
//

import UIKit
class SettingsVC: UIViewController,UIPickerViewDataSource,UIPickerViewDelegate  {
    var chartView:BarChartViewController?
    
    @IBOutlet weak var myPicker: UIPickerView!
    @IBOutlet weak var myLabel: UILabel!
    let easeOptions = ["Linear","Quad","Cubic","Quart","Quint","Sex","Sine","Cosine","Expo","Circ","Elastic", "Back", "Bounce"]
    override func viewDidLoad() {
        super.viewDidLoad()
        myPicker.dataSource = self
        myPicker.delegate = self
    }
    
    //MARK: - Delegates and data sources
    //MARK: Data Sources
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return easeOptions.count
    }
    
    //MARK: Delegates
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return easeOptions[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        //myLabel.text = pickerData[row]
        if let barChartVC = self.chartView {
            switch easeOptions[row] {
            case "Linear":
                barChartVC.easeOption = .Linear
            case "Quad":
                barChartVC.easeOption = .EaseInOutQuad
            case "Cubic":
                barChartVC.easeOption = .EaseInOutCubic
            case "Quart":
                barChartVC.easeOption = .EaseInOutQuart
            case "Quint":
                barChartVC.easeOption = .EaseInOutQuint
            case "Sex":
                barChartVC.easeOption = .EaseInOutSex
            case "Sine":
                barChartVC.easeOption = .EaseInOutSine
            case "Cosine":
                barChartVC.easeOption = .EaseInOutCosine
            case "Expo":
                barChartVC.easeOption = .EaseInOutExpo
            case "Circ":
                barChartVC.easeOption = .EaseInOutCirc
            case "Elastic":
                barChartVC.easeOption = .EaseInOutElastic
            
            default: break
                
            }
        }
    }
}

