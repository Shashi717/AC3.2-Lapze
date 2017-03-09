//
//  CreateChallengeViewController.swift
//  Lapze
//
//  Created by Ilmira Estil on 3/7/17.
//  Copyright © 2017 Lapze Inc. All rights reserved.
//

import UIKit
import SnapKit
import FirebaseDatabase
import FirebaseAuth
import CoreLocation

protocol ChallengeDelegate {
    func startChallenge(user: String, linkRef: FIRDatabaseReference)
   // var challengeRef: FIRDatabaseReference? { get set }
}

class CreateChallengeViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, CLLocationManagerDelegate {
    
    let activities: [Activity] = [.running, .cycling, .skateBoarding, .rollerSkating, .basketBall, .soccer]
    let noTimeLimitActivities: [Activity] = [.running, .cycling, .skateBoarding, .rollerSkating]
    var currentPickerType: DatePickerType = .date
    var shareLocation = false
    var shareProfile = false
    var delegate: ChallengeDelegate?

    let databaseRef = FIRDatabase.database().reference()
    var challengeRef: FIRDatabaseReference!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Create Challenge"
        self.view.backgroundColor = ColorPalette.spaceGrayColor
        
        setupViewHierarchy()
        configureConstraints()
    }
    
    //MARK: - Utilities
    func locationSwitchValueChanged(sender: UISwitch) {
        print("Before status: \(shareLocation)")
        shareLocation = !shareLocation
        print("Now status: \(shareLocation)")
    }
    
    func privacySwitchValueChanged(sender: UISwitch) {
        shareProfile = !shareProfile
    }
    
    func cancelButtonTapped(sender: UIBarButtonItem) {
        print("cancel tapped")
        _ = navigationController?.popViewController(animated: true)
    }
    
    func doneButtonTapped(sender: UIBarButtonItem) {
        
        print("done tapped")
        createChallenge()

       _ = self.navigationController?.popViewController(animated: true)
    }
    
    func createChallenge() {
        let user = FIRAuth.auth()!.currentUser!.uid
        let dict = ["champion": user, "lastUpdated":pickedDateLabel.text!,"name": challengeNameTextField.text!, "type": pickedActivityLabel.text!] as [String : Any]
        
        let linkRef = self.databaseRef.childByAutoId()
        challengeRef = databaseRef.child("Challenge").child(linkRef.key)
        challengeRef.updateChildValues(dict)
        
  
        self.delegate?.startChallenge(user: user, linkRef: challengeRef)
    }
    
    func showDatePicker() {
        for view in pickerContainer.subviews {
            view.removeFromSuperview()
        }
        self.pickerContainer.addSubview(datePicker)
        datePicker.snp.makeConstraints { (view) in
            view.top.bottom.left.right.equalToSuperview()
        }
    }
    
    func showActivityPicker() {
        for view in pickerContainer.subviews {
            view.removeFromSuperview()
        }
        self.pickerContainer.addSubview(activityPickerView)
        activityPickerView.delegate = self
        activityPickerView.dataSource = self
        activityPickerView.snp.makeConstraints { (view) in
            view.top.bottom.left.right.equalToSuperview()
        }
    }
    
    func activityLabelTapped(sender:UITapGestureRecognizer) {
        showActivityPicker()
    }
    
    func dateLabelTapped(sender:UITapGestureRecognizer) {
        currentPickerType = .date
        datePicker.datePickerMode = .date
        showDatePicker()
    }
    
    func startTimeLabelTapped(sender:UITapGestureRecognizer) {
        currentPickerType = .startTime
        datePicker.datePickerMode = .time
        showDatePicker()
    }
    
    func endTimeLabelTapped(sender:UITapGestureRecognizer) {
        currentPickerType = .endTime
        datePicker.datePickerMode = .time
        showDatePicker()
    }
    
    func datePicked(sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        switch currentPickerType {
        case DatePickerType.date:
            datePicker.datePickerMode = UIDatePickerMode.date
            dateFormatter.dateFormat = "MMM dd, yyyy"
            pickedDateLabel.text = dateFormatter.string(from: datePicker.date)
        case DatePickerType.startTime:
            datePicker.datePickerMode = UIDatePickerMode.time
            dateFormatter.dateFormat = "hh:mm a"
            pickedStartTimeLabel.text = dateFormatter.string(from: datePicker.date)
        case DatePickerType.endTime:
            datePicker.datePickerMode = UIDatePickerMode.time
            dateFormatter.dateFormat = "hh:mm a"
            pickedEndTimeLabel.text = dateFormatter.string(from: datePicker.date)
        }
    }
    
    //MARK: - Delegates and data sources
    
    //MARK: Data Sources
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return activities.count
    }
    
    //MARK: Delegates
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return activities[row].rawValue
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        let pickedActivity = activities[row]
        pickedActivityLabel.text = pickedActivity.rawValue
        
        //end time can only be configured for certain activities
        if noTimeLimitActivities.contains(pickedActivity) {
            pickedEndTimeLabel.isUserInteractionEnabled = false
        }
        else {
            pickedEndTimeLabel.isUserInteractionEnabled = true
        }
        
    }
    //MARK: - Setup
    
    func setupViewHierarchy() {
        self.edgesForExtendedLayout = []
        
        navigationItem.leftBarButtonItem = cancelButton
        navigationItem.rightBarButtonItem = doneButton
        self.view.addSubview(challengeNameContainer)
        self.view.addSubview(activityContainer)
        self.view.addSubview(dateContainer)
        self.view.addSubview(pickerContainer)
        self.challengeNameContainer.addSubview(challengeNameLabel)
        self.challengeNameContainer.addSubview(challengeNameTextField)
        self.activityContainer.addSubview(activityLabel)
        self.activityContainer.addSubview(pickedActivityLabel)
        self.dateContainer.addSubview(dateLabel)
        self.dateContainer.addSubview(pickedDateLabel)
    }
    
    func configureConstraints() {
        challengeNameContainer.snp.makeConstraints { (view) in
            view.top.equalToSuperview().offset(22.0)
            view.left.right.equalToSuperview()
            view.height.equalTo(44.0)
        }
        activityContainer.snp.makeConstraints { (view) in
            view.top.equalTo(challengeNameContainer.snp.bottom).offset(22.0)
            view.left.right.equalToSuperview()
            view.height.equalTo(44.0)
        }
        dateContainer.snp.makeConstraints { (view) in
            view.top.equalTo(activityContainer.snp.bottom).offset(22.0)
            view.left.right.equalToSuperview()
            view.height.equalTo(44.0)
        }
        challengeNameLabel.snp.makeConstraints { (view) in
            view.top.bottom.equalToSuperview()
            view.left.equalToSuperview().offset(16.0)
            view.width.equalTo(135.0)
        }
        challengeNameTextField.snp.makeConstraints { (view) in
            view.top.bottom.equalToSuperview()
            view.right.equalToSuperview().inset(16.0)
            view.width.equalTo(175.0)
        }
        activityLabel.snp.makeConstraints { (view) in
            view.top.bottom.equalToSuperview()
            view.left.equalToSuperview().offset(16.0)
            view.width.equalTo(100.0)
        }
        pickedActivityLabel.snp.makeConstraints { (view) in
            view.top.bottom.equalToSuperview()
            view.right.equalToSuperview().inset(16.0)
            view.width.equalTo(150.0)
        }
        dateLabel.snp.makeConstraints { (view) in
            view.top.bottom.equalToSuperview()
            view.left.equalToSuperview().offset(16.0)
            view.width.equalTo(100.0)
        }
        pickedDateLabel.snp.makeConstraints { (view) in
            view.top.bottom.equalToSuperview()
            view.right.equalToSuperview().inset(16.0)
            view.width.equalTo(150.0)
        }
        pickerContainer.snp.makeConstraints { (view) in
            view.bottom.left.right.equalToSuperview()
        }
    }
    
    //MARK: - Views
    // Acitivity, Date, Start Time, End, Location, Public
    
    internal lazy var challengeNameContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    internal lazy var activityContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    internal lazy var dateContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    internal lazy var startTimeContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    internal lazy var endTimeContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    internal lazy var locationContainer: UIView! = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    internal lazy var privacyContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    internal lazy var pickerContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    internal lazy var challengeNameLabel: UILabel = {
        let label = UILabel()
        label.text = "Challenge Name"
        return label
    }()
    internal lazy var activityLabel: UILabel = {
        let label = UILabel()
        label.text = "Activity"
        return label
    }()
    internal lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.text = "Date"
        return label
    }()
    internal lazy var startTimeLabel: UILabel = {
        let label = UILabel()
        label.text = "Start"
        return label
    }()
    internal lazy var endTimeLabel: UILabel = {
        let label = UILabel()
        label.text = "End"
        return label
    }()
    internal lazy var challengeNameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Add a description"
        textField.textAlignment = .right
        return textField
    }()
    internal lazy var pickedActivityLabel: UILabel = {
        let label = UILabel()
        label.text = "..."
        label.textColor = .lightGray
        label.textAlignment = .right
        label.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(activityLabelTapped(sender:)))
        label.addGestureRecognizer(tap)
        return label
    }()
    
    internal lazy var pickedDateLabel: UILabel = {
        let label = UILabel()
        label.text = "..."
        label.textColor = .lightGray
        label.textAlignment = .right
        label.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(dateLabelTapped(sender:)))
        label.addGestureRecognizer(tap)
        return label
    }()
    internal lazy var pickedStartTimeLabel: UILabel = {
        let label = UILabel()
        label.text = "..."
        label.textColor = .lightGray
        label.textAlignment = .right
        label.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(startTimeLabelTapped(sender:)))
        label.addGestureRecognizer(tap)
        return label
    }()
    internal lazy var pickedEndTimeLabel: UILabel = {
        let label = UILabel()
        label.text = "..."
        label.textColor = .lightGray
        label.textAlignment = .right
        label.isUserInteractionEnabled = false
        let tap = UITapGestureRecognizer(target: self, action: #selector(endTimeLabelTapped(sender:)))
        label.addGestureRecognizer(tap)
        return label
    }()
    internal lazy var privacyLabel: UILabel = {
        let label = UILabel()
        label.text = "PRIVACY"
        label.textColor = .gray
        label.font = label.font.withSize(14)
        label.textAlignment = .left
        return label
    }()
    internal lazy var locationLabel: UILabel = {
        let label = UILabel()
        label.text = "Location"
        return label
    }()
    internal lazy var sharingStatusLabel: UILabel = {
        let label = UILabel()
        label.text = "Public Mode"
        return label
    }()
    internal lazy var locationSwitch: UISwitch = {
        let theSwitch = UISwitch()
        theSwitch.addTarget(self, action: #selector(locationSwitchValueChanged(sender:)), for: .valueChanged)
        return theSwitch
    }()
    internal lazy var privacySwitch: UISwitch = {
        let theSwitch = UISwitch()
        theSwitch.addTarget(self, action: #selector(privacySwitchValueChanged(sender:)), for: .valueChanged)
        return theSwitch
    }()
    internal lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.addTarget(self, action: #selector(datePicked(sender:)), for: .valueChanged)
        return datePicker
    }()
    internal lazy var activityPickerView: UIPickerView = {
        let pickerView = UIPickerView()
        return pickerView
    }()
    internal lazy var doneButton: UIBarButtonItem = {
        var barButton = UIBarButtonItem()
        barButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonTapped(sender:)))
        return barButton
    }()
    internal lazy var cancelButton: UIBarButtonItem = {
        var barButton = UIBarButtonItem()
        barButton = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(cancelButtonTapped(sender:)))
        return barButton
    }()
    
}
