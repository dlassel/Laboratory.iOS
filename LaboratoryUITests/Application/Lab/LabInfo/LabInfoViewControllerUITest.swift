//
//  LabInfoViewControllerUITest.swift
//  LaboratoryUITests
//
//  Created by Developers on 6/14/19.
//  Copyright © 2019 2Letters. All rights reserved.
//

import XCTest

class LabInfoViewControllerUITest: MyUITestDelegate {

    var app: XCUIApplication!
    var thisViewController: MyViewController!
    var nameTextField: XCUIElement!
    var descriptionTextField: XCUIElement!
    var nameText: String!
    var descriptionText: String!
    override func setUp() {
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        app = XCUIApplication()
        app.launch()
        thisViewController = .labInfo
        
        goToLabInfoViewController()
        
        nameTextField = app.textFields[AccessibilityId.labInfoNameTextField.value]
        descriptionTextField = app.textFields[AccessibilityId.labInfoDescriptionTextField.value]
        nameText = nameTextField.value as? String
        descriptionText = descriptionTextField.value as? String
    }
    
    override func tearDown() {
        app = nil
        nameTextField = nil
        descriptionTextField = nil
        super.tearDown()
    }
    
    func testViewsExist() {
        let saveBtn = app.buttons[AccessibilityId.labInfoSaveButton.value]
        let addEquipmentsBtn = app.buttons[AccessibilityId.labInfoAddEquipmentButton.value]
        let tableView = app.tables[AccessibilityId.labInfoTableView.value]
        XCTAssertTrue(saveBtn.exists)
        XCTAssertTrue(addEquipmentsBtn.exists)
        XCTAssertTrue(tableView.exists)
        XCTAssertTrue(nameTextField.exists)
        XCTAssertTrue(descriptionTextField.exists)
    }
    
    func testDismissKeyboard() {
        // THEN
        // Test name text field
        nameTextField.tap()
        XCTAssert(app.keyboards.count > 0)
        nameTextField.typeSomeText()
        
        tapOutside()
        // todo: fail
        XCTAssertEqual(app.keyboards.count, 0)
        
        nameTextField.tap()
        XCTAssert(app.keyboards.count > 0)
        
        swipeView(inVC: thisViewController)
        XCTAssertEqual(app.keyboards.count, 0)
        
        // Test description text field
        descriptionTextField.tap()
        XCTAssert(app.keyboards.count > 0)
        descriptionTextField.typeText("la")
        
        tapOutside()
        XCTAssertEqual(app.keyboards.count, 0)
        
        descriptionTextField.tap()
        XCTAssert(app.keyboards.count > 0)
        
        swipeView(inVC: thisViewController)
        XCTAssertEqual(app.keyboards.count, 0)
    }
    
    func testAddEquipmentButtonHittable()  {
        let addEquipmentButton = app.buttons[AccessibilityId.labInfoAddEquipmentButton.value]
        // todo: fail
        XCTAssertTrue(addEquipmentButton.isHittable)
    }
    
    func testInvalidInput() {
        nameTextField.clearText()
        descriptionTextField.clearText()
        let alert = app.alerts[AlertCase.invalidLabInfoInput.description]
        // todo: fail
        XCTAssertTrue(alert.exists)
        // close the alert
        proceedAlertButton(ofAlert: alert)
        
        // redo the text
        nameTextField.typeText(nameText)
        descriptionTextField.typeText(descriptionText)
    }
    
    func testSucceedAlertShowed() {
        let saveButton = app.buttons[AccessibilityId.labInfoSaveButton.value]
        // todo: fail
        XCTAssertTrue(saveButton.isEnabled)
        
        saveButton.tap()
        let alert = app.alerts[AlertCase.succeedToSaveLab.description]
        XCTAssertTrue(alert.exists)
        proceedAlertButton(ofAlert: alert)
    }
}