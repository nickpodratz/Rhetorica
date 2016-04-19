//
//  RhetoricaUITests.swift
//  RhetoricaUITests
//
//  Created by Nick Podratz on 12.04.16.
//  Copyright © 2016 Nick Podratz. All rights reserved.
//

import XCTest

class RhetoricaUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        
        let app = XCUIApplication()
        app.launchEnvironment = [ "isUITest": "true" ]
//        app.launchArguments = ["testMode"]
        setupSnapshot(app)
        app.launch()
        
        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testTakeScreenshots() {
        
        // Setup app
        let app = XCUIApplication()
//        app.launchEnvironment = [ "UITest": "1" ]
//        app.launchArguments = ["testMode"]
//        // setLanguage(app)
//        setupSnapshot(app)
        
        let mainVC_tableView = app.tables.elementBoundByIndex(0)
        let mainVC_listButton = app.buttons.matchingIdentifier("MainVC_ListMenuButton").element

        // Choose device for detailVC (for iPad where detailVC persists)
        mainVC_tableView.staticTexts["Alliteration"].tap()
        
        // Pop back to mainVC if device is NOT iPad
        if !mainVC_listButton.exists || !mainVC_listButton.hittable {
            app.navigationBars.elementBoundByIndex(0).buttons.elementBoundByIndex(0).tap()
        }
        
        // Present ListVC
        mainVC_listButton.tap() //MainVC_NavigationBar
        
        // Select AllDevices list
        let listVC_tableView = app.tables.elementBoundByIndex(0)
        let listVC_allDevicesCell = listVC_tableView.cells.matchingIdentifier("ListVC_AllDevicesCell").element
        listVC_allDevicesCell.tap()
        
        snapshot("5Settings")

        // Pop back to mainVC
        let listVC_navigationBar = app.navigationBars.matchingIdentifier("listVC_NavigationBar").element
        let listVC_doneButton = listVC_navigationBar.buttons.matchingIdentifier("ListVC_DoneButton").element
        listVC_doneButton.tap()
        
        listVC_tableView.swipeUp()
        listVC_tableView.swipeUp()
        listVC_tableView.swipeUp()
        listVC_tableView.swipeUp()
        
        snapshot("4TableView")
        
        // Choose device for detailVC snapshot
        if listVC_tableView.staticTexts["Telling Name"].exists {
            listVC_tableView.staticTexts["Telling Name"].tap()

        } else if listVC_tableView.staticTexts["Euphemismus"].exists {
            listVC_tableView.staticTexts["Euphemismus"].tap()

        } else {
            listVC_tableView.staticTexts["Inversion"].tap()
        }
        
        snapshot("1DetailView")
        
        let detailVC_navigationBar = app.navigationBars.matchingIdentifier("DetailVC_NavigationBar").element
        if !detailVC_navigationBar.exists || !detailVC_navigationBar.hittable {
            // Pop back to mainVC
            app.navigationBars.elementBoundByIndex(0).buttons.elementBoundByIndex(0).tap()
        }
        
        // Show QuizVC
        let mainVC_quizButton = app.buttons.matchingIdentifier("MainVC_QuizMenuButton").element
        mainVC_quizButton.tap()
        
        sleep(3)
        
        let quizRightAnswerButton = app.buttons.matchingIdentifier("QuizVC_AnswerButton").elementBoundByIndex(1)
        quizRightAnswerButton.tap()
        NSThread.sleepForTimeInterval(0.4)
        snapshot("2Quiz")
        
        sleep(2)
        
        snapshot("3UserStats")

    }
}
