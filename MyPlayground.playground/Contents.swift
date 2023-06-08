import UIKit
import Foundation

var greeting = "Hello, playground"

//let highestTotalDistance: Double = 15350
//let count = max(String(Int(highestTotalDistance)).count - 1, 1)
//let power = pow(Double(10), Double(count))
//let threshhold = Int(ceil(highestTotalDistance / power) * power)
//print(Double(threshhold))
//let percentage = (100 * 15350) / Double(threshhold)
//
//let result = (percentage * 200) / 100

let value: Double = 2001
let count = max(String(Int(value)).count - 1, 1)
let power = pow(Double(10), Double(count))
let threshhold = Int(ceil(value / power) * power)
