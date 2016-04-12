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
        app.launchEnvironment = [ "UITest": "1" ]
        setLanguage(app)
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
        let app = XCUIApplication()
        
        // Select right device list
        app.navigationBars.elementBoundByIndex(0).buttons["list"].tap()
        app.tables.staticTexts["All Devices"].tap()
        app.navigationBars["Extent"].buttons["Done"].tap()
       
        snapshot("0Launch")
        
//        let tableView = app.tables.elementBoundByIndex(0)
//        tableView
//        
//        let cell = app.staticTexts["Allusion"]
//        let start = cell.coordinateWithNormalizedOffset(CGVectorMake(0, 0))
//        let finish = cell.coordinateWithNormalizedOffset(CGVectorMake(0, 6))
//        start.pressForDuration(0, thenDragToCoordinate: finish)
//
//        app.scrollViews.otherElements.icons["Rhetorica"].tap()
//        
//
//        let tablesQuery = XCUIApplication().tables
//        tablesQuery.childrenMatchingType(.Other).matchingIdentifier("table index").elementBoundByIndex(0).tap()
//        tablesQuery.cells.containingType(.StaticText, identifier:"Salutatio").childrenMatchingType(.StaticText).matchingIdentifier("Salutatio").elementBoundByIndex(0).tap()
//        tablesQuery.cells.containingType(.StaticText, identifier:"Repetition").childrenMatchingType(.StaticText).matchingIdentifier("Repetition").elementBoundByIndex(0).tap()
//        tablesQuery.staticTexts["Rhetorical Question"].tap()
//        
//        snapshot("1detailVC")
//
//        let hyperboleStaticText = app.tables.staticTexts["Hyperbole"]
//        hyperboleStaticText.tap()
//        hyperboleStaticText.tap()
//        app.childrenMatchingType(.Window).elementBoundByIndex(1).childrenMatchingType(.Other).elementBoundByIndex(1).childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).elementBoundByIndex(0).childrenMatchingType(.ScrollView).element.tap()
//        app.typeText("")
    
    }
}
