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
    var leafs=[String]()
    var leafFractions = [Double]()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        for var index = 0; index < product!.leafs.count; index++ {
             var originalLeafName = product!.leafs[index]
             if originalLeafName.hasPrefix("Leaf_") {
                let startIndex = originalLeafName.startIndex.advancedBy(5)
                originalLeafName = originalLeafName.substringFromIndex(startIndex)
            }
            
            leafs.append(originalLeafName)
            leafFractions.append(product!.leafFractions[index]*100.0)
        }
        setChart(leafs, values:leafFractions)
    }

    func setChart(dataPoints: [String], values: [Double]) {
        barChartView.noDataText = "You need to provide data for the chart."
        
        var dataEntries: [BarChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
           let dataEntry = BarChartDataEntry(value: values[i], xIndex: i)
           dataEntries.append(dataEntry)
        }
                     
        let chartDataSet = BarChartDataSet(yVals: dataEntries, label: "Percentage")
        let chartData = BarChartData(xVals: leafs, dataSet: chartDataSet)
        barChartView.data = chartData
        barChartView.descriptionText = ""
        chartDataSet.colors = ChartColorTemplates.pastel()
        barChartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0, easingOption: .EaseInOutElastic)
        barChartView.xAxis.labelPosition = .Bottom
        barChartView.backgroundColor = UIColor(red: 189/255, green: 195/255, blue: 199/255, alpha: 1)

    }
}

