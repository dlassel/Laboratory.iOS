//
//  LabCreateUITest.swift
//  LaboratoryUITests
//
//  Created by Developers on 6/24/19.
//  Copyright © 2019 2Letters. All rights reserved.
//

import XCTest

class LabCreateUITest: MyUITestDelegate {

    var app: XCUIApplication!
    var nameTextView: XCUIElement!
    var descriptionTextView: XCUIElement!
    override func setUp() {
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        app = XCUIApplication()
        app.launch()
        goToLabCreate()
        nameTextView = app.textViews[AccessibilityId.labInfoNameTextView.description]
        descriptionTextView = app.textViews[AccessibilityId.labInfoDescriptionTextView.description]
    }
    
    override func tearDown() {
        app = nil
        nameTextView = nil
        descriptionTextView = nil
        super.tearDown()
    }

    func testViewsExist() {
        let saveBtn = app.buttons[AccessibilityId.labInfoSaveButton.description]
        let addEquipmentsBtn = app.buttons[AccessibilityId.labInfoAddEquipmentButton.description]
        let deleteLabButton = app.buttons[AccessibilityId.labInfoDeleteLabButton.description]
        let tableView = app.tables[AccessibilityId.labInfoTableView.description]
        
        XCTAssertFalse(saveBtn.isEnabled)
        XCTAssertTrue(addEquipmentsBtn.exists)
        XCTAssertFalse(deleteLabButton.exists)
        XCTAssertTrue(tableView.exists)
        XCTAssertTrue(nameTextView.exists)
        XCTAssertTrue(descriptionTextView.exists)
    }
    
    func testInvalidInput() {
        let addEquipmentsBtn = app.buttons[AccessibilityId.labInfoAddEquipmentButton.description]
        
        addEquipmentsBtn.tap()
        sleep(2)
        
        //        let alert = app.alerts[AlertCase.invalidLabInfoInput.description]
        //        XCTAssertTrue(alert.exists)
        // close the alert
        proceedAlertButton(ofCase: .invalidLabInfoInput)
    }
    
    func testAddEquipments() {
        let labName = "A Unit Test Lab Name 1"
        let labDescription = "Please delete meeeeeee. Dont even ask"
        
        let addEquipmentsBtn = app.buttons[AccessibilityId.labInfoAddEquipmentButton.description]
        
        nameTextView.tap()
        nameTextView.typeText(labName)
        
        descriptionTextView.tap()
        descriptionTextView.typeText(labDescription)
        
        addEquipmentsBtn.tap()
        sleep(2)
        // press no
        proceedAlertButton(ofCase: .attemptCreateLab)
        
        addEquipmentsBtn.tap()
        sleep(2)
        // press Yes
        app.buttons[AlertString.yes].tap()
    }
}
