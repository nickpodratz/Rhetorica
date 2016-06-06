//
//  QuizQuestion.swift
//  Rhetorica
//
//  Created by Nick Podratz on 30.10.15.
//  Copyright © 2015 Nick Podratz. All rights reserved.
//

import Foundation

class Question {
    var devices: [StylisticDevice]
    var tagOfCorrectAnswer: Int
    var answerWasCorrect: Bool?
    
    var correctAnswer: StylisticDevice {
        return devices[tagOfCorrectAnswer]
    }
    
    init(devices: [StylisticDevice], tagOfCorrectAnswer: Int, answerWasCorrect: Bool? = nil) {
        self.devices = devices
        self.tagOfCorrectAnswer = tagOfCorrectAnswer
        self.answerWasCorrect = answerWasCorrect
    }

    convenience init(devices: [StylisticDevice]) {
        let tagOfCorrectAnswer = Int(arc4random_uniform(UInt32(devices.count)))
        self.init(devices: devices, tagOfCorrectAnswer: tagOfCorrectAnswer)
    }
}


// MARK: QuizQuestion + Init from DeviceList

extension Question {
    convenience init(fromDeviceList deviceList: DeviceList, tagOfCorrectAnswer: Int, numberOfQuestions: Int = 4) {
        var newDevices = [StylisticDevice]()
        for _ in 0 ..< numberOfQuestions {
            var newRandomDevice: StylisticDevice
            repeat {
                newRandomDevice = deviceList.getRandomDevice()
            } while (newDevices.contains(newRandomDevice))
            
            newDevices.append(newRandomDevice)
        }
        
        self.init(devices: newDevices, tagOfCorrectAnswer: tagOfCorrectAnswer)
    }
    
    convenience init(fromDeviceList deviceList: DeviceList, numberOfQuestions: Int = 4) {
        let tagOfCorrectAnswer = Int(arc4random_uniform(UInt32(numberOfQuestions)))
        self.init(fromDeviceList: deviceList, tagOfCorrectAnswer: tagOfCorrectAnswer)
    }
    
//    convenience init(withCorrectDevice correctDevice: StylisticDevice, fromDeviceList deviceList: DeviceList, numberOfQuestions: Int = 4) {
//        devices = []
//        for _ in 0 ..< (numberOfQuestions - 1) {
//            var newRandomDevice: StylisticDevice
//            repeat {
//                newRandomDevice = deviceList.getRandomDevice()
//            } while (devices.contains(newRandomDevice))
//            
//            devices.append(newRandomDevice)
//        }
//        
//        tagOfCorrectAnswer = Int(arc4random_uniform(UInt32(numberOfQuestions)))
//        
//        devices.insert(correctDevice, atIndex: tagOfCorrectAnswer)
//    }

}