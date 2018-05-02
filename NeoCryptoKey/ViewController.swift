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
    @IBAction func calculate(_ sender: UIButton) {
        printString()
    }
    // ALL VARIABLE DECLARATIONS
    // loadData Stores Here
    var oldPrice: Double = 0.0
    // Lists for Picker View
    let monthArray = [1,3,6,12,24,36]
    let coinArray = ["BTC","LTC","XRP","ETH", "ZEC"]
    var stringMonthArray: [String] = [String]()
    // apiURL declaration
    var apiUrl = ""
    // date declaration
    var date = NSDate()
    // date constants
    var timestamp = UInt64(0)
    var monthTime = UInt64(2629743)
    var nowStr = ""
    var oldStr = ""
    
    //UI PICKER STUFF
    var pickerData: [[String]] = [[String]]()
    var currencyChosen = ""
    var monthsChosen = 0
    
    var currentPrice = 0.0
    var olderPrice = 0.0
    var gainVal = 0.0
    let myGroup = DispatchGroup()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        // MORE PICKER STUFF
        
        timestamp = UInt64(floor(date.timeIntervalSince1970)) - UInt64(86400)
        nowStr = String(timestamp)
        
        self.picker.delegate = self
        self.picker.dataSource = self
        
        for x in monthArray{
            stringMonthArray.append("\(x) Months")
        }
        pickerData = [coinArray,stringMonthArray]
        print("Finished ViewDidLoad")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //PICKER VIEW DELEGATES
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        //print("Finished numberOfComponents")
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
            print(currencyChosen)
        }
        else {
            monthsChosen = monthArray[row]
            print(monthsChosen)
        }
        print("Finished pickerView3")
    }
    
    func printString()
    {
        print("Start Print")
        myGroup.enter()
        loadData(nowStr, currencyChosen)
        print("Completed First Load")
        currentPrice = oldPrice
        myGroup.leave()
        //myGroup.enter()
        getVals()
        loadData(oldStr, currencyChosen)
        print("Completed Second Load")
        olderPrice = oldPrice
        //myGroup.leave()
        let amountBought :Double? = Double(coinsBought.text!)
        print(amountBought!)
        print(currentPrice)
        print(olderPrice)
        gainVal = (amountBought!*currentPrice) - (amountBought!*olderPrice)
        outputString.text = "You would have made \(gainVal) USD if you had invested \((amountBought!*olderPrice)) USD in \(currencyChosen) \(monthsChosen) Months ago"
        print("Completed String")
    }
    
    // RESETS VARIBALES ACCORDING TO MONTH
    func getVals(){
        timestamp = UInt64(floor(date.timeIntervalSince1970))
        oldStr = String((timestamp-(monthTime*UInt64(monthsChosen))))
        //print(timestamp)
        //print(currentMonthStr)
        print("Completed getVals")
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
                                self.oldPrice = fabs(close.doubleValue)
                                print("Close price: \(self.oldPrice)")
                            }
                        }
                    }
                }
        }
    }
    
    
}
