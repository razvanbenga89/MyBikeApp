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


let number = 2000000

let formatter = NumberFormatter()
formatter.numberStyle = .decimal
formatter.groupingSeparator = "."
formatter.groupingSize = 3

if let formattedString = formatter.string(from: NSNumber(value: number)) {
  print(formattedString) // Output: 2.000
}
