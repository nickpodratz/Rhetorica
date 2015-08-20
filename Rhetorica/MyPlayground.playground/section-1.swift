// Playground - noun: a place where people can play

import Foundation

var str = "Hello, playground"
str.rangeOfString("el")
var elements = ["defe","fwefw","fwef","wef","fe","wef","fewa"]

let animals = ["cat", "dog", "turtle", "swift", "elephant"]

print(animals.map{$0})

let searchKey = "og"
animals.filter{$0.rangeOfString(searchKey)}
