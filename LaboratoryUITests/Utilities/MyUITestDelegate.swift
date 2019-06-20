//
//  MyUITestDelegate.swift
//  LaboratoryUITests
//
//  Created by Developers on 6/14/19.
//  Copyright © 2019 2Letters. All rights reserved.
//

import XCTest

protocol UITestable {
    var app: XCUIApplication! { get set }
    // Switch taps
    func goToFirstTab()
    func goToSecondTab()
    
    // Switch view controllers
    func goToLabCollectionViewController()
    func goToLabInfoViewController()
    func goToLabEquipmentSelectionViewController()
    func goToLabEquipmentEditViewController()
    func goToEquipmentListViewController()
    func goToEquipmentInfoViewController()
    
    // Interactions
    func tapOutside(inVC viewController: MyViewController)
    func swipeView(inVC viewController: MyViewController, toView destinationView: XCUIElement?)
    func getSearchBar(inVC viewController: MyViewController) -> XCUIElement?
    func getFirstCell(inVC viewController: MyViewController) -> XCUIElement?
    func proceedAlertButton(ofCase alertCase: AlertCase)
}

extension UITestable where Self: XCTestCase {
    // MARK: - Switch Tabs
    func goToFirstTab() {
        let tabBarButtons = XCUIApplication().tabBars.buttons
        tabBarButtons.element(boundBy: 0).tap()
    }
    
    func goToSecondTab() {
        let tabBarButtons = XCUIApplication().tabBars.buttons
        tabBarButtons.element(boundBy: 1).tap()
    }
    
    // MARK: - Switch View Controllers
    func goToLabCollectionViewController() {
        return
    }
    func goToLabInfoViewController() {
        goToLabCollectionViewController()
        let firstCell = getFirstCell(inVC: .labCollection)!
        firstCell.tap()
    }
    func goToLabEquipmentSelectionViewController() {
        goToLabInfoViewController()
        let addEquipmentButton = app.buttons[AccessibilityId.labInfoAddEquipmentButton.value]
        addEquipmentButton.tap()
    }
    func goToLabEquipmentEditViewController() {
        goToLabEquipmentSelectionViewController()
        let firstCell = getFirstCell(inVC: .labEquipmentSelection)!
        firstCell.tap()
    }
    func goToEquipmentListViewController() {
        goToSecondTab()
    }
    func goToEquipmentInfoViewController() {
        goToEquipmentListViewController()
        let firstCell = getFirstCell(inVC: .equipmentList)!
        firstCell.tap()
    }
    
    
    // MARK: - Interactions
    func tapOutside(inVC viewController: MyViewController) {
        let mainView: XCUIElement
        switch viewController {
        case .labInfo:
            mainView = app.otherElements[AccessibilityId.labInfoMainView.value]
        case .labEquipmentEdit:
            mainView = app.scrollViews[AccessibilityId.labEquipmentEditScrollView.value]
        default:
            return
        }
        
        let coordinate = mainView.coordinate(withNormalizedOffset: CGVector.zero).withOffset(CGVector(dx: 10,dy: 1))
        coordinate.tap()
    }
    
    func swipeView(inVC viewController: MyViewController, toView destinationView: XCUIElement? = nil) {
        let view: XCUIElement
        switch viewController {
        case .labCollection:
            view = app.collectionViews[AccessibilityId.labCollectionView.value]
        case .labInfo:
            view = app.tables[AccessibilityId.labInfoTableView.value]
        case .labEquipmentSelection:
            view = app.tables[AccessibilityId.labEquipmentSelectionTableView.value]
        case .labEquipmentEdit:
            view = app.scrollViews[AccessibilityId.labEquipmentEditScrollView.value]
        case .equipmentList:
            view = app.tables[AccessibilityId.equipmentListTableView.value
            ]
        case .equipmentInfo:
            // todo fix this case, this is made up
            view = app.otherElements[AccessibilityId.equipmentInfoScrollView.value]
        }
//        let searchBar = getSearchBar(inVC: viewController)!
        if let destinationView = destinationView {
            view.cells.element(boundBy: 0).press(forDuration: 1, thenDragTo: destinationView)
        } else {
            view.swipeUp()
        }
    }
    
    func getSearchBar(inVC viewController: MyViewController) -> XCUIElement? {
        let searchBar: XCUIElement?
        switch viewController {
        case .labCollection:
            searchBar = app.otherElements[AccessibilityId.labCollectionSearchBar.value]
        case .labEquipmentSelection:
            searchBar = app.otherElements[AccessibilityId.labEquipmentSelectionSearchBar.value]
        case .equipmentList:
            searchBar = app.otherElements[AccessibilityId.equipmentListSearchBar.value]
        default:
            return nil
        }
        return searchBar
    }
    
//    func typeTextSearchBar(inVC viewController: MyViewController) {
//        let searchBar: XCUIElement?
//        switch viewController {
//        case .labCollection:
//            searchBar = app.otherElements[AccessibilityId.labCollectionSearchBar.value]
//        default:
//            searchBar = nil
//        }
//        searchBar?.typeText("la")
//    }
    
//    func cancelSearchBar(inVC viewController: MyViewController) {
//        let cancelSearchBtn: XCUIElement?
//        cancelSearchBtn = app/*@START_MENU_TOKEN@*/.otherElements["labCollectionSearchBar"].searchFields/*[[".otherElements[\"labCollectionSearchBar\"].searchFields",".searchFields"],[[[-1,1],[-1,0]]],[1]]@END_MENU_TOKEN@*/.buttons["Clear text"]
//        XCTAssertNotNil(cancelSearchBtn)
//        XCTAssertTrue(cancelSearchBtn!.exists)
//        cancelSearchBtn!.tap()
//    }
    
    func getFirstCell(inVC viewController: MyViewController) -> XCUIElement? {
        switch viewController {
        case .labCollection:
            return app.collectionViews[AccessibilityId.labCollectionView.value].cells.element(boundBy: 0)
        case .labEquipmentSelection:
            return app.tables[AccessibilityId.labEquipmentSelectionTableView.value].cells.element(boundBy: 0)
        case .equipmentList:
            return app.tables[AccessibilityId.equipmentListTableView.value].cells.element(boundBy: 0)
        default:
            return nil
        }
    }
    
    func proceedAlertButton(ofCase alertCase: AlertCase) {
        let buttonText: String
        
        switch alertCase {
        case .invalidLabInfoInput,
             .failToSaveLab,
             .succeedToSaveLab,
             .failToLoadEquipments,
             .failToLoadLabEquipments,
             .failToLoadEquipmentInfo,
             .failToSaveEquipmentEdit:
            buttonText = AlertString.okay
            
        case .createLabToAddEquipments:
            buttonText = AlertString.yes
        }
        
        let alertButton = app.buttons[buttonText]
        alertButton.tap()
    }
}

typealias MyUITestDelegate = XCTestCase & UITestable
