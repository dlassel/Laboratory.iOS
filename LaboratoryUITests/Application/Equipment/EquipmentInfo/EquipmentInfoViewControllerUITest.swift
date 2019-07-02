//
//  EquipmentInfoViewControllerUITest.swift
//  LaboratoryUITests
//
//  Created by Developers on 7/2/19.
//  Copyright © 2019 2Letters. All rights reserved.
//

import XCTest

class EquipmentInfoViewControllerUITest: MyUITestDelegate {

    var app: XCUIApplication!
    var thisViewController: MyViewController!
    override func setUp() {
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        app = XCUIApplication()
        app.launch()
        thisViewController = .equipmentInfo
    }
    
    override func tearDown() {
        app = nil
        thisViewController = nil
        super.tearDown()
    }

    func testBackButton() {
        let backButton = app.navigationBars.buttons.element(boundBy: 0)
        
        XCTAssertTrue(backButton.exists)
        backButton.tap()
        
        sleep(2)
        let equipmentListSearchBar = getSearchBar(inVC: .equipmentList)!
        XCTAssertTrue(equipmentListSearchBar.exists)
    }
    
    func testViewsExist() {
        let editSaveBtn = app.buttons[AccessibilityId.equipmentInfoEditSaveButton.description]
        let availableTextField = app.textFields[AccessibilityId.equipmentInfoAvailableTextField.description]
        let nameTextView = app.textViews[AccessibilityId.equipmentInfoNameTextView.description]
        let locationTextView = app.textViews[AccessibilityId.equipmentInfoLocationTextView.description]
        let descriptionTextView = app.textViews[AccessibilityId.equipmentInfoDescriptionTextView.description]
        let imageView = app.images[AccessibilityId.equipmentInfoImageView.description]
        let addImageButton = app.buttons[AccessibilityId.equipmentInfoAddImageButton.description]
        let removeEquipmentButton = app.buttons[AccessibilityId.equipmentInfoRemoveEquipmentButton.description]
        let listOfUserButton = app.buttons[AccessibilityId.equipmentInfoListOfUserButton.description]
        
        XCTAssertTrue(editSaveBtn.exists)
        XCTAssertTrue(availableTextField.exists)
        XCTAssertTrue(nameTextView.exists)
        XCTAssertTrue(locationTextView.exists)
        XCTAssertTrue(descriptionTextView.exists)
        XCTAssertTrue(imageView.exists)
        XCTAssertTrue(addImageButton.exists)
        XCTAssertFalse(addImageButton.isHittable)
        XCTAssertTrue(removeEquipmentButton.exists)
        XCTAssertFalse(removeEquipmentButton.isHittable)
        XCTAssertTrue(listOfUserButton.exists)
    }
    
    func testTextFieldEndEditing() {
        // TODO
    }
    
    func testTextViewShouldChangeText() {
        // WHEN
        nameTextView.tap()
        nameTextView.deleteAllText()
        nameTextView.typeSomeText(withLength: 101)
        
        // THEN
        let nameText = nameTextView.value as! String
        XCTAssertEqual(nameText.count, MyInt.nameTextLimit)
        
        // WHEN
        descriptionTextView.tap()
        descriptionTextView.deleteAllText()
        descriptionTextView.typeSomeText(withLength: 501)
        
        // THEN
        let descriptionText = descriptionTextView.value as! String
        XCTAssertEqual(descriptionText.count, MyInt.descriptionTextLimit)
    }
    
    func testInvalidInput() {
        sleep(2)
        // clear all inputs
        nameTextView.tap()
        nameTextView.deleteAllText()
        descriptionTextView.tap()
        descriptionTextView.deleteAllText()
        
        let saveButton = app.buttons[AccessibilityId.labInfoSaveButton.description]
        saveButton.tap()
        sleep(2)
        
        //        let alert = app.alerts[AlertCase.invalidLabInfoInput.description]
        //        XCTAssertTrue(alert.exists)
        // close the alert
        proceedAlertButton(ofCase: .invalidLabInfoInput)
    }
    
    func testAddEquipmentButtonHittable()  {
        let addEquipmentButton = app.buttons[AccessibilityId.labInfoAddEquipmentButton.description]
        sleep(2)
        XCTAssertTrue(addEquipmentButton.isHittable)
    }
    
    func testRemoveButton() {
        let removeLabButton = app.buttons[AccessibilityId.labInfoRemoveLabButton.description]
        sleep(2)
        XCTAssertTrue(removeLabButton.isHittable)
        
        removeLabButton.tap()
        sleep(2)
        
        XCTAssertTrue(app.buttons[AlertString.yes].exists)
        XCTAssertTrue(app.buttons[AlertString.no].exists)
        
        proceedAlertButton(ofCase: .attemptToRemoveLab)
    }
    
    func testDismissKeyboard() {
        // THEN
        // Test name text field
        nameTextView.tap()
        XCTAssert(app.keyboards.count > 0)
        nameTextView.typeSomeText()
        
        tapOutside(inVC: thisViewController)
        XCTAssertEqual(app.keyboards.count, 0)
        
        nameTextView.tap()
        XCTAssert(app.keyboards.count > 0)
        
        swipeView(inVC: thisViewController, toView: descriptionTextView)
        sleep(2)
        XCTAssertEqual(app.keyboards.count, 0)
        
        // Test description text field
        descriptionTextView.tap()
        XCTAssert(app.keyboards.count > 0)
        descriptionTextView.typeText("la")
        
        tapOutside(inVC: thisViewController)
        XCTAssertEqual(app.keyboards.count, 0)
        
        descriptionTextView.tap()
        XCTAssert(app.keyboards.count > 0)
        
        swipeView(inVC: thisViewController, toView: descriptionTextView)
        XCTAssertEqual(app.keyboards.count, 0)
    }
    
    func testSucceedAlertShowed() {
        let saveButton = app.buttons[AccessibilityId.labInfoSaveButton.description]
        
        // do some text change to enable saveButton
        sleep(2)
        let nameText = nameTextView.value as! String
        nameTextView.tap()
        nameTextView.deleteAllText()
        nameTextView.typeText(nameText)
        XCTAssertTrue(saveButton.isEnabled)
        
        
        saveButton.tap()
        sleep(2)
        // tap on alert button
        let alert = app.alerts[AlertCase.succeedToSaveLab.description]
        XCTAssertTrue(alert.exists)
        proceedAlertButton(ofCase: .succeedToSaveLab)
    }
}
