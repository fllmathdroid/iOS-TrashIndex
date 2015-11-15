//
//  BarChartViewController.swift
//  iOSChartsDemo
//
//  Created by Joyce Echessa on 6/12/15.
//  Copyright (c) 2015 Appcoda. All rights reserved.
//

import UIKit
import Charts

@objc class BarChartViewController: UIViewController {
    @IBOutlet weak var barChartView: BarChartView!
    var product:Product?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        setChart(product!.leafs, values:product!.leafFractions)
    }

    func setChart(dataPoints: [String], values: [Double]) {
        barChartView.noDataText = "You need to provide data for the chart."
        
        var dataEntries: [BarChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
           let dataEntry = BarChartDataEntry(value: values[i], xIndex: i)
           dataEntries.append(dataEntry)
        }
                     
        let chartDataSet = BarChartDataSet(yVals: dataEntries, label: "Material")
        let chartData = BarChartData(xVals: product!.leafs, dataSet: chartDataSet)
        barChartView.data = chartData   
    }
}

