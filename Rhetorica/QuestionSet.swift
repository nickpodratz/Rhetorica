//
//  QuizQuestionSet.swift
//  Rhetorica
//
//  Created by Nick Podratz on 30.10.15.
//  Copyright © 2015 Nick Podratz. All rights reserved.
//

import Foundation

class QuestionSet: NSObject {
    let language: Language!
    let extend: String!
    
    let numberOfQuestions: Int
    let questions: [Question]
    private var questionIndex = -1
    var currentQuestion: Question? {
        if questionIndex >= questions.count {
            return nil
        }
        return questions[questionIndex]
    }
    var numberOfCurrentQuestion: Int {
        return questionIndex + 1
    }
    
    init(fromDeviceList deviceList: DeviceList, language: Language, numberOfQuestions: Int) {
        self.numberOfQuestions = numberOfQuestions
        self.questions = QuestionSet.generateQuestions(fromDeviceList: deviceList, numberOfQuestions: numberOfQuestions)
        self.language = language
        self.extend = deviceList.title
        super.init()
    }
    
    func nextQuestion() -> Question? {
        ++questionIndex
        return currentQuestion
    }
    
    private static func generateQuestions(fromDeviceList deviceList: DeviceList, numberOfQuestions: Int) -> [Question] {
        var generatedQuestions = [Question]()
        for _ in 0 ..< numberOfQuestions {
            var newQuestion = Question(fromDeviceList: deviceList)
            while ( numberOfQuestions < deviceList.elements.count && generatedQuestions.map{$0.correctAnswer}.contains(newQuestion.correctAnswer)) {
                newQuestion = Question(fromDeviceList: deviceList)
            }
            generatedQuestions.append(newQuestion)
        }
        return generatedQuestions
    }
    
}


// MARK: - QuestionSet + Question filtering

extension QuestionSet {
    var correctAnsweredQuestions: [Question] {
        return questions.filter({ question in
            return question.answerWasCorrect == true
        })
    }
    
    var wrongAnsweredQuestions: [Question] {
        return questions.filter({ question in
            return question.answerWasCorrect == false
        })
    }
    
    var notAnsweredQuestions: [Question] {
        return questions.filter({ question in
            return question.answerWasCorrect == nil
        })
    }
}


// MARK: - QuestionSet: CustomStringConvertible

extension QuestionSet {
    override var description: String {
        return "QuestionSet with \(numberOfQuestions) questions, current question: \(questionIndex)."
    }
}