//
//  LabInfoViewController.swift
//  Laboratory
//
//  Created by Developers on 5/17/19.
//  Copyright © 2019 2Letters. All rights reserved.
//

import UIKit

// for both LabInfoViewController and LabCreateVC
class LabInfoViewController: UIViewController, SpinnerPresentable, AlertPresentable {
    var isCreatingNewLab: Bool = false
    var labId: String?

    @IBOutlet private var mainView: UIView!
    
    var spinnerVC = SpinnerViewController()
    private var labInfoView: LabInfoView!
    private var saveBtn: UIBarButtonItem!
    private var labEquipmentTableView: UITableView!
    
    private var viewModel = LabInfoViewModel()
    private let cellReuseIdAndNibName = "LabEquipmentTVCell"
    private let presentEquipmentSelectionSegue = "presentEquipmentSelection"
    private let unwindFromLabInfoSegue = "unwindFromLabInfo"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addTapRecognizer()
        
        addMainView()
        setupUI()
        
        if !isCreatingNewLab {
            showSpinner()
            loadLabInfo()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isCreatingNewLab {
            navigationItem.title = "Create a Lab"
            labInfoView.deleteLabButton.isHidden = true
        } else {
            navigationItem.title = "Edit Lab"
            labInfoView.deleteLabButton.isHidden = false
        }
    }
    
    // MARK: Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == presentEquipmentSelectionSegue {
            let navC = segue.destination as! UINavigationController
            let labEquipmentSelectionVC = navC.viewControllers.first as! LabEquipmentSelectionVC
            labEquipmentSelectionVC.labId = labId
        }
    }
    
    @IBAction private func unwindFromEquipmentSelection(segue: UIStoryboardSegue) {
        // there's some change, reload table view and enable save Button
        isCreatingNewLab = false
        loadLabInfo()
        saveBtn.isEnabled = true
    }
    
    // MARK: Layout
    private func addMainView() {
        labInfoView = LabInfoView.instantiate()
        labInfoView.removeFromSuperview()
        mainView.addSubview(labInfoView)
        labInfoView.frame = mainView.bounds
        labInfoView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
    
    private func setupUI() {
        saveBtn = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveButtonTapped))
        navigationItem.rightBarButtonItem = saveBtn
        
        registerCell()
        
        setupAddEquipmentButton()
        
        let deleteLabButton = labInfoView.deleteLabButton!
        deleteLabButton.addTarget(self, action: #selector(attemptToDeleteLab), for: .touchUpInside)
        
        // disable Save button until some change is made
        saveBtn.isEnabled = false
        
        addDelegates()
        addIdentifiers()
    }
    
    private func registerCell() {
        labEquipmentTableView = labInfoView.labEquipmentTableView
        let nib = UINib(nibName: cellReuseIdAndNibName, bundle: nil)
        labEquipmentTableView.register(nib, forCellReuseIdentifier: cellReuseIdAndNibName)
    }
    
    private func setupAddEquipmentButton() {
        let addEquipmentButton = labInfoView.addEquipmentButton!
        if isCreatingNewLab {
            addEquipmentButton.setTitle("Add Equipments", for: .normal)
            addEquipmentButton.addTarget(self, action: #selector(addEquipments), for: .touchUpInside)
        } else {
            addEquipmentButton.setTitle("Edit Equipments", for: .normal)
            addEquipmentButton.addTarget(self, action: #selector(editEquipments), for: .touchUpInside)
        }
    }
    
    private func addDelegates() {
        labEquipmentTableView.delegate = self
        labEquipmentTableView.dataSource = self
        labEquipmentTableView.keyboardDismissMode = .onDrag
        labInfoView.nameTextView.delegate = self
        labInfoView.descriptionTextView.delegate = self
    }
    
    private func addIdentifiers() {
        mainView.accessibilityIdentifier = AccessibilityId.labInfoMainView.description
        saveBtn.accessibilityIdentifier = AccessibilityId.labInfoSaveButton.description
    }
    
    private func loadLabInfo() {
        viewModel.labId = labId
        // start fetching Lab Equipments
        viewModel.fetchLabInfo { [weak self] (fetchResult) in
            guard let self = self else { return }
            switch fetchResult {
            case .success:
                DispatchQueue.main.async {
                    // updateUI
                    self.labInfoView.labInfoVM = self.viewModel
                    self.labEquipmentTableView?.reloadData()
                }
                self.hideSpinner()
            case let .failure(errorStr):
                print(errorStr)
                self.presentAlert(forCase: .failToLoadLabEquipments, handler: { action in
                    self.goBackAndReload()
                })
            }
        }
    }
}


// MARK: - User Interaction
extension LabInfoViewController {
    private func goBackAndReload() {
        self.performSegue(withIdentifier: unwindFromLabInfoSegue, sender: nil)
    }
    
    private func goToEquipmentsSelect() {
        performSegue(withIdentifier: presentEquipmentSelectionSegue, sender: nil)
    }
    
    @objc private func editEquipments() {
        goToEquipmentsSelect()
    }
    
    @objc private func addEquipments() {
        if isCreatingNewLab {
            presentAlert(forCase: .attemptCreateLab, handler: { action in
                self.attemptToSaveLab(onSaveButtonTapped: true)
            })
//            attemptToAddEquipments
//
//            let newLabName = labInfoView.nameTextView.text ?? ""
//            let newLabDescription = labInfoView.descriptionTextView.text ?? ""
//
//            if (newLabName.isEmpty || newLabDescription.isEmpty) {
//                presentAlert(forCase: .invalidLabInfoInput)
//            } else {
//
//            }
        } else {
            goToEquipmentsSelect()
        }
    }
    
//    @objc private func
    
    @objc private func attemptToDeleteLab() {
        presentAlert(forCase: .attemptToDeleteLab, handler: deleteLab)
    }
    
    private func deleteLab(alert: UIAlertAction!) {
        viewModel.deleteLab(withId: labId!) { [weak self] (deleteResult) in
            guard let self = self else { return }
            switch deleteResult {
            case let .failure(errorStr):
                print(errorStr)
                self.presentAlert(forCase: .failToDeleteLab)
            case .success:
                self.goBackAndReload()
            }
        }
    }
    
    @objc private func saveButtonTapped() {
        attemptToSaveLab(onSaveButtonTapped: false)
    }
    
    private func attemptToSaveLab(onSaveButtonTapped: Bool) {
        let newLabName = labInfoView.nameTextView.text ?? ""
        let newLabDescription = labInfoView.descriptionTextView.text ?? ""

        if (newLabName.isEmpty || newLabDescription.isEmpty) {
            presentAlert(forCase: .invalidLabInfoInput)
        } else {
            if isCreatingNewLab {
                viewModel.setupLabInfo(withLabName: newLabName, description: newLabDescription)
            } else {
                viewModel.labName = newLabName
                viewModel.description = newLabDescription
            }
            
            saveLab(onSaveButtonTapped: onSaveButtonTapped)
        }
    }
    
    private func saveLab(onSaveButtonTapped: Bool) {
        viewModel.saveLab() { [weak self] (updateResult) in
            guard let self = self else { return }
            switch updateResult {
            case let .failure(errorStr):
                print(errorStr)
                self.presentAlert(forCase: .failToSaveLab)
            case let .success(newLabId):
                if onSaveButtonTapped {
                    // TODO: test this
                    // Successfully created a new Lab, to add Equipments
                    self.isCreatingNewLab = false
                    self.labId = newLabId
                    self.viewModel.labId = newLabId
                    self.goToEquipmentsSelect()
                } else {    // Save button pressed
                    self.presentAlert(forCase: .succeedToSaveLab, handler: { action in
                        self.goBackAndReload()
                    })
                }
            }
        }
    }
}


// MARK: - Table View
extension LabInfoViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.equipmentVMs?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell: LabEquipmentTVCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdAndNibName, for: indexPath) as! LabEquipmentTVCell
        
        cell.viewModel = viewModel.equipmentVMs?[indexPath.row]
        return cell
    }
}

extension LabInfoViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        // there's some change, enable save Button
        
        saveBtn.isEnabled = true
        textView.highlight()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.warnInput()
        } else {
            textView.unhighlight()
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        var textLimit = 0
        
        if textView == labInfoView.nameTextView {
            textLimit = MyInt.nameTextLimit
        } else if textView == labInfoView.descriptionTextView {
            textLimit = MyInt.descriptionTextLimit
        }
        
        return textView.text.count + text.count - range.length < textLimit + 1
    }
}
