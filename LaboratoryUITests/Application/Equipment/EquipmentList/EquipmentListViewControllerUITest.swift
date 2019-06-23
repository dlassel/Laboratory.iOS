//
//  EquipmentListViewControllerUITest.swift
//  LaboratoryUITests
//
//  Created by Huy Vo on 6/16/19.
//  Copyright © 2019 2Letters. All rights reserved.
//

import XCTest

class EquipmentListViewControllerUITest: MyUITestDelegate {
    var app: XCUIApplication!
    var thisViewController: MyViewController!
    override func setUp() {
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        app = XCUIApplication()
        app.launch()
        thisViewController = .equipmentList
        goToEquipmentListViewController()
    }
    
    override func tearDown() {
        app = nil
        thisViewController = nil
        super.tearDown()
    }
    
    func testViewsExist() {
        let addButton = app.buttons[AccessibilityId.equipmentListAddButton.description]
        let searchBar = getSearchBar(inVC: thisViewController)!
        let equipmentTV = app.tables[AccessibilityId.equipmentListTableView.description]
        
        XCTAssertTrue(addButton.exists)
        XCTAssertTrue(searchBar.exists)
        XCTAssertTrue(equipmentTV.exists)
    }
    
    func testDismissKeyboard() {
        let searchBar = getSearchBar(inVC: thisViewController)!
        
        searchBar.tap()
        XCTAssert(app.keyboards.count > 0)
        searchBar.typeSomeText()
        searchBar.clearText()
        
        swipeView(inVC: thisViewController)
        XCTAssertEqual(app.keyboards.count, 0)
        
        searchBar.tap()
        XCTAssert(app.keyboards.count > 0)
    }
    
    func testFirstCellHittable() {
        let firstCell = getFirstCell(inVC: thisViewController)!
        XCTAssertTrue(firstCell.isHittable)
    }
}
