//
//  ViewController.swift
//  NeoCryptoKey
//
//  Created by Rohan Pahwa on 5/1/18.
//  Copyright © 2018 Pahwa. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var outputString: UILabel!
    @IBOutlet weak var coinsBought: UITextField!
    // ALL VARIABLE DECLARATIONS
    var oldPrice: Double = 0.0
    
    let monthArray = [1,3,6,12,24,36]
    let coinArray = ["BTC","LTC","XRP","ETH", "ZEC"]
    var stringMonthArray: [String] = [String]()
    var currentMonth: Int = 0
    var currentCoin: String = ""
    
    var apiUrl = ""
    var date = NSDate()
    
    var timestamp = UInt64(0)
    var monthTime = UInt64(2629743)
   
    var timeStampFixed = ""
    var currentMonthStr = ""
    //UI PICKER STUFF
    var pickerData: [[String]] = [[String]]()
    var currencyChosen = ""
    var monthsChosen = 0
    
    var amountBought = 0.0
    var currentPrice = 0.0
    var oldPricen = 0.0

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        currentCoin = "BTC"
        currentMonth = 3
        print("Calling loadData()")
        getVals()
        loadData(currentMonthStr,currentCoin)
        // MORE PICKER STUFF
        self.picker.delegate = self
        self.picker.dataSource = self
        for x in monthArray{
            stringMonthArray.append("\(x) Months")
        }
        
        pickerData = [coinArray,stringMonthArray]
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //PICKER VIEW DELEGATES
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData[component].count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[component][row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // This method is triggered whenever the user makes a change to the picker selection.
        // The parameter named row and component represents what was selected.
        if component == 0 {
            currencyChosen = coinArray[row]
        }
        else {
            monthsChosen = row
        }
        printString()
    }
    
    func printString()
    {
        
        outputString.text = "You would have made \(oldPrice) if you had invested \(oldPrice) in \(currencyChosen) \(monthArray[monthsChosen]) Months ago"
    }
    
    // RESETS VARIBALES ACCORDING TO MONTH
    func getVals(){
        timestamp = UInt64(floor(date.timeIntervalSince1970))
        currentMonthStr = String((timestamp-(monthTime*UInt64(currentMonth))))
        print(timestamp)
        print(currentMonthStr)
    }
    
    //USES ALAMO AND SWIFTY TO PULL DATA FROM cryptocompare API
    func loadData(_ currentMonthStr: String,_ currentCoin: String) {
        apiUrl = "https://min-api.cryptocompare.com/data/histoday?fsym=\(currentCoin)&tsym=USD&limit=1&toTs=\(currentMonthStr)"

        Alamofire.request(apiUrl, method: .post, parameters: nil, encoding: JSONEncoding.default)
            .responseJSON { response in
                if let status = response.response?.statusCode {
                    switch(status){
                    case 200:
                        print("Successful API call")
                    default:
                        print("Response status: \(status)")
                    }
                }
                if let result = response.result.value {
                    let JSON = result as! NSDictionary
                    if let dict = JSON.value(forKey: "Data") {
                        let swiftArr = dict as? NSArray
                        // May need to change 0 to a 1
                        print(type(of: swiftArr![0]))
                        if let swiftDict = swiftArr![0] as? NSDictionary {
                            if let close = swiftDict.value(forKey: "close") as? NSNumber {
                                print("Close price pre-guard: \(close) of type \(type(of: close))")
                                self.oldPrice = fabs(close.doubleValue)
                                print("Close price: \(self.oldPrice)")
                            }
                        }
                    }
                }
        }
    }
    
    
}
