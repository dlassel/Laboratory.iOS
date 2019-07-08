//
//  LabEquipmentEditVC.swift
//  Laboratory
//
//  Created by Developers on 5/23/19.
//  Copyright © 2019 2Letters. All rights reserved.
//

import UIKit

class LabEquipmentEditVC: UIViewController, SpinnerPresentable, AlertPresentable {
    // to receive data from LabEquipmentSelectionVC
    var labId: String!
    var equipmentId: String!
    // the original using quantiy
    var usingQuantity: Int = 0
    // the quantity being edited

    @IBOutlet private var usingQuantityTextField: MyTextField!
    @IBOutlet private var decreaseBtn: UIButton!
    @IBOutlet private var increaseBtn: UIButton!
    @IBOutlet private var removeBtn: UIButton!
    @IBOutlet private var separatingLine: UIView!
    @IBOutlet private var scrollView: UIScrollView!
    private var equipmentInfoView: EquipmentInfoView!
    
    private var saveBtn: UIBarButtonItem!
    var spinnerVC = SpinnerViewController()
    private var viewModel = LabEquipmentEditVM()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        addTapRecognizer()
        addEquipmentInfoView()
        
        viewModel.usingQuantity = usingQuantity
        
        setupUI()
        showSpinner()
        loadEquipmentInfo()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueId.showEquipmentUserListFromLab {
            let equipmentUserListVC = segue.destination as! EquipmentUserListVC
            equipmentUserListVC.equipmentId = sender as? String
        }
    }
    
    
    // MARK: - Layout
    private func addEquipmentInfoView() {
        equipmentInfoView = EquipmentInfoView.instantiate(forCase: .equipmentInfoLabEdit)
        scrollView.addSubview(equipmentInfoView)
        
        equipmentInfoView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            equipmentInfoView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 0),
            equipmentInfoView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: 0),
            equipmentInfoView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 0),
            equipmentInfoView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: 0),
            
            equipmentInfoView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: 0),
            equipmentInfoView.heightAnchor.constraint(equalTo: view.heightAnchor, constant: 0),
            ])
    }
    
    private func setupUI() {
        saveBtn = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveChange))
        navigationItem.rightBarButtonItem = saveBtn
        saveBtn.isEnabled = false
        
        // quantity only accept numbers
        usingQuantityTextField.keyboardType = .numberPad
        usingQuantityTextField.textAlignment = .center
        usingQuantityTextField.delegate = self
        
        decreaseBtn.setTitleColor(MyColor.lightLavender, for: .normal)
        increaseBtn.setTitleColor(MyColor.lightLavender, for: .normal)
        removeBtn.setTitleColor(MyColor.redWarning, for: .normal)
        removeBtn.titleLabel?.font = UIFont(name: secondaryFont, size: 17)
        
        separatingLine.backgroundColor = MyColor.lightGray

        equipmentInfoView.update(forEditing: false)
        equipmentInfoView.listOfUserButton.addTarget(self, action: #selector(showListOfUser), for: .touchUpInside)
        
        scrollView.keyboardDismissMode = .onDrag
        addIdentifiers()
    }
    
    private func addIdentifiers() {
        scrollView.accessibilityIdentifier = AccessibilityId.labEquipmentEditScrollView.description
        saveBtn.accessibilityIdentifier = AccessibilityId.labEquipmentEditSaveButton.description
        usingQuantityTextField.accessibilityIdentifier = AccessibilityId.labEquipmentEditUsingQuantityTextField.description
        decreaseBtn.accessibilityIdentifier = AccessibilityId.labEquipmentEditDecreaseButton.description
        increaseBtn.accessibilityIdentifier = AccessibilityId.labEquipmentEditIncreaseButton.description
        removeBtn.accessibilityIdentifier = AccessibilityId.labEquipmentEditRemoveButton.description
    }
    
    private func loadEquipmentInfo() {
        guard let equipmentId = equipmentId else {
            presentAlert(forCase: .failToLoadEquipmentInfo, handler: goBack)
            return
        }
        viewModel.equipmentInfoVM.fetchEquipmentInfo(byId: equipmentId) { [weak self] (fetchResult) in
            guard let self = self else { return }
            switch fetchResult {
            case .success:
                DispatchQueue.main.async {
                    self.equipmentInfoView.viewModel = self.viewModel.equipmentInfoVM
                    self.updateUI()
                }
                self.hideSpinner()
            case .failure:
                // show an alert and return to the previous page
                self.presentAlert(forCase: .failToLoadEquipmentInfo, handler: self.goBack)
            }
        }
    }
    
    private func updateUI() {
        // Quantity Layout
        usingQuantityTextField.text = String(viewModel.editingQuantity)
        
        decreaseBtn.isEnabled = viewModel.isDecreaseBtnEnabled
        increaseBtn.isEnabled = viewModel.isIncreaseBtnEnabled
        removeBtn.isEnabled = viewModel.isRemoveBtnEnabled
        
        saveBtn.isEnabled = viewModel.isSaveBtnEnabled 
    }
    
    
    // MARK: - User Interaction
    @objc private func saveChange() {
        viewModel.updateEquipmentUsing(forLabId: labId, equipmentId: equipmentId) { [weak self] (updateFirestoreResult) in
            guard let self = self else { return }
            switch updateFirestoreResult {
            case let .failure(errorStr):
                print(errorStr)
                // show an alert and return to the previous page
                self.presentAlert(forCase: .failToSaveEdit)
            case .success:
                self.goBackAndReload()
            }
        }
    }
    
    @IBAction private func decreaseEquipment(_ sender: UIButton) {
        viewModel.editingQuantity -= 1
        updateUI()
    }
    
    @IBAction private func increaseEquipment(_ sender: UIButton) {
        viewModel.editingQuantity += 1
        updateUI()
    }
    
    @IBAction private func removeEquipment(_ sender: UIButton) {
        // set quantity to 0
        viewModel.editingQuantity = 0
        updateUI()
    }
    
    @objc private func showListOfUser() {
        performSegue(withIdentifier: SegueId.showEquipmentUserListFromLab, sender: equipmentId)
    }
    
    private func goBack(alert: UIAlertAction!) {
        // go back to Equipment Selection
        navigationController?.popViewController(animated: true)
    }
    
    private func goBackAndReload() {
        // go back to Equipment Selection
        performSegue(withIdentifier: SegueId.unwindFromEquipmentEdit, sender: nil)
    }
}

extension LabEquipmentEditVC: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == usingQuantityTextField {
            usingQuantityTextField.highlight()
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == usingQuantityTextField {
            usingQuantityTextField.unhighlight()
        }
        viewModel.updateQuantityTextField(withText: textField.text)
        updateUI()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let inputLength = textField.text?.count ?? 0 + string.count - range.length
        return inputLength < (MyInt.quantityTextLimit + 1)
    }
}
