//
//  CreateEventViewController.swift
//  Lapze
//
//  Created by Madushani Lekam Wasam Liyanage on 3/3/17.
//  Copyright © 2017 Lapze Inc. All rights reserved.
//

import UIKit
import SnapKit

public enum Activity: String {
    case running = "Running"
    case cycling = "Cycling"
    case skateBoarding = "Skate Boarding"
    case rollerSkating = "Roller Skating"
    case basketBall = "Basketball"
    case soccer = "Soccer"
}

enum DatePickerType {
    case date
    case startTime
    case endTime
}

protocol EventDelegate{
    func startEvent(name: String)
}

class CreateEventViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    let activities: [Activity] = [.running, .cycling, .skateBoarding, .rollerSkating, .basketBall, .soccer]
    let noTimeLimitActivities: [Activity] = [.running, .cycling, .skateBoarding, .rollerSkating]
    var currentPickerType: DatePickerType = .date
    var delegate: EventDelegate?
    var shareLocation = false
    var shareProfile = false
    private var userEventInfo: [String:String] = ["type":"","date":"","start":"","end":""]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Create Event"
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
        dismissViewcontroller()
    }
    
    func doneButtonTapped(sender: UIBarButtonItem) {
        print("done tapped")
        dismissViewcontroller()
        getEventInfo()
        self.delegate?.startEvent(name: "test")
    }
    
    func dismissViewcontroller(){
        self.navigationController?.popViewController(animated: true)
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
            userEventInfo["date"] = dateFormatter.string(from: datePicker.date)
        case DatePickerType.startTime:
            datePicker.datePickerMode = UIDatePickerMode.time
            dateFormatter.dateFormat = "hh:mm a"
            pickedStartTimeLabel.text = dateFormatter.string(from: datePicker.date)
            userEventInfo["start"] = dateFormatter.string(from: datePicker.date)
        case DatePickerType.endTime:
            datePicker.datePickerMode = UIDatePickerMode.time
            dateFormatter.dateFormat = "hh:mm a"
            pickedEndTimeLabel.text = dateFormatter.string(from: datePicker.date)
            userEventInfo["end"] = dateFormatter.string(from: datePicker.date)
        }
    }
    
    private func getEventInfo(){
        print(userEventInfo)
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
        userEventInfo["type"] = pickedActivity.rawValue
        
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
        self.view.addSubview(activityContainer)
        self.view.addSubview(dateContainer)
        self.view.addSubview(startTimeContainer)
        self.view.addSubview(endTimeContainer)
        self.view.addSubview(privacyLabel)
        self.view.addSubview(locationContainer)
        self.view.addSubview(privacyContainer)
        self.view.addSubview(pickerContainer)
        self.activityContainer.addSubview(activityLabel)
        self.activityContainer.addSubview(pickedActivityLabel)
        self.dateContainer.addSubview(dateLabel)
        self.dateContainer.addSubview(pickedDateLabel)
        self.startTimeContainer.addSubview(startTimeLabel)
        self.startTimeContainer.addSubview(pickedStartTimeLabel)
        self.endTimeContainer.addSubview(endTimeLabel)
        self.endTimeContainer.addSubview(pickedEndTimeLabel)
        self.locationContainer.addSubview(locationLabel)
        self.locationContainer.addSubview(locationSwitch)
        self.privacyContainer.addSubview(sharingStatusLabel)
        self.privacyContainer.addSubview(privacySwitch)
    }
    
    func configureConstraints() {
        activityContainer.snp.makeConstraints { (view) in
            view.top.equalToSuperview().offset(22.0)
            view.left.right.equalToSuperview()
            view.height.equalTo(44.0)
        }
        dateContainer.snp.makeConstraints { (view) in
            view.top.equalTo(activityContainer.snp.bottom).offset(22.0)
            view.left.right.equalToSuperview()
            view.height.equalTo(44.0)
        }
        startTimeContainer.snp.makeConstraints { (view) in
            view.top.equalTo(dateContainer.snp.bottom).offset(1.0)
            view.left.right.equalToSuperview()
            view.height.equalTo(44.0)
        }
        endTimeContainer.snp.makeConstraints { (view) in
            view.top.equalTo(startTimeContainer.snp.bottom).offset(1.0)
            view.left.right.equalToSuperview()
            view.height.equalTo(44.0)
        }
        privacyLabel.snp.makeConstraints { (view) in
            view.top.equalTo(endTimeContainer.snp.bottom).offset(22.0)
            view.left.equalToSuperview().offset(16.0)
            view.height.equalTo(26.0)
        }
        locationContainer.snp.makeConstraints { (view) in
            view.top.equalTo(privacyLabel.snp.bottom)
            view.left.right.equalToSuperview()
            view.height.equalTo(44.0)
        }
        privacyContainer.snp.makeConstraints { (view) in
            view.top.equalTo(locationContainer.snp.bottom).offset(1.0)
            view.left.right.equalToSuperview()
            view.height.equalTo(44.0)
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
        startTimeLabel.snp.makeConstraints { (view) in
            view.top.bottom.equalToSuperview()
            view.left.equalToSuperview().offset(16.0)
            view.width.equalTo(100.0)
        }
        pickedStartTimeLabel.snp.makeConstraints { (view) in
            view.top.bottom.equalToSuperview()
            view.right.equalToSuperview().inset(16.0)
            view.width.equalTo(150.0)
        }
        endTimeLabel.snp.makeConstraints { (view) in
            view.top.bottom.equalToSuperview()
            view.left.equalToSuperview().offset(16.0)
            view.width.equalTo(100.0)
        }
        pickedEndTimeLabel.snp.makeConstraints { (view) in
            view.top.bottom.equalToSuperview()
            view.right.equalToSuperview().inset(16.0)
            view.width.equalTo(150.0)
        }
        locationLabel.snp.makeConstraints { (view) in
            view.top.bottom.equalToSuperview()
            view.left.equalToSuperview().offset(16.0)
            view.width.equalTo(100.0)
        }
        locationSwitch.snp.makeConstraints { (view) in
            view.centerY.equalToSuperview()
            view.right.equalToSuperview().inset(16.0)
        }
        sharingStatusLabel.snp.makeConstraints { (view) in
            view.top.bottom.equalToSuperview()
            view.left.equalToSuperview().offset(16.0)
            view.width.equalTo(100.0)
        }
        privacySwitch.snp.makeConstraints { (view) in
            view.centerY.equalToSuperview()
            view.right.equalToSuperview().inset(16.0)
        }
        pickerContainer.snp.makeConstraints { (view) in
            view.top.equalTo(privacyContainer.snp.bottom).offset(16.0)
            view.bottom.left.right.equalToSuperview()
        }
    }
    
    //MARK: - Views
    // Acitivity, Date, Start Time, End, Location, Public
    
    internal lazy var activityContainer: UIView! = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    internal lazy var dateContainer: UIView! = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    internal lazy var startTimeContainer: UIView! = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    internal lazy var endTimeContainer: UIView! = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    internal lazy var locationContainer: UIView! = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    internal lazy var privacyContainer: UIView! = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    internal lazy var pickerContainer: UIView! = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    internal lazy var activityLabel: UILabel! = {
        let label = UILabel()
        label.text = "Activity"
        return label
    }()
    internal lazy var dateLabel: UILabel! = {
        let label = UILabel()
        label.text = "Date"
        return label
    }()
    internal lazy var startTimeLabel: UILabel! = {
        let label = UILabel()
        label.text = "Start"
        return label
    }()
    internal lazy var endTimeLabel: UILabel! = {
        let label = UILabel()
        label.text = "End"
        return label
    }()
    internal lazy var pickedActivityLabel: UILabel! = {
        let label = UILabel()
        label.text = "..."
        label.textColor = .lightGray
        label.textAlignment = .right
        label.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(activityLabelTapped(sender:)))
        label.addGestureRecognizer(tap)
        return label
    }()
    
    internal lazy var pickedDateLabel: UILabel! = {
        let label = UILabel()
        label.text = "..."
        label.textColor = .lightGray
        label.textAlignment = .right
        label.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(dateLabelTapped(sender:)))
        label.addGestureRecognizer(tap)
        return label
    }()
    internal lazy var pickedStartTimeLabel: UILabel! = {
        let label = UILabel()
        label.text = "..."
        label.textColor = .lightGray
        label.textAlignment = .right
        label.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(startTimeLabelTapped(sender:)))
        label.addGestureRecognizer(tap)
        return label
    }()
    internal lazy var pickedEndTimeLabel: UILabel! = {
        let label = UILabel()
        label.text = "..."
        label.textColor = .lightGray
        label.textAlignment = .right
        label.isUserInteractionEnabled = false
        let tap = UITapGestureRecognizer(target: self, action: #selector(endTimeLabelTapped(sender:)))
        label.addGestureRecognizer(tap)
        return label
    }()
    internal lazy var privacyLabel: UILabel! = {
        let label = UILabel()
        label.text = "PRIVACY"
        label.textColor = .gray
        label.font = label.font.withSize(14)
        label.textAlignment = .left
        return label
    }()
    internal lazy var locationLabel: UILabel! = {
        let label = UILabel()
        label.text = "Location"
        return label
    }()
    internal lazy var sharingStatusLabel: UILabel! = {
        let label = UILabel()
        label.text = "Public Mode"
        return label
    }()
    internal lazy var locationSwitch: UISwitch! = {
        let theSwitch = UISwitch()
        theSwitch.addTarget(self, action: #selector(locationSwitchValueChanged(sender:)), for: .valueChanged)
        return theSwitch
    }()
    internal lazy var privacySwitch: UISwitch! = {
        let theSwitch = UISwitch()
        theSwitch.addTarget(self, action: #selector(privacySwitchValueChanged(sender:)), for: .valueChanged)
        return theSwitch
    }()
    internal lazy var datePicker: UIDatePicker! = {
        let datePicker = UIDatePicker()
        datePicker.addTarget(self, action: #selector(datePicked(sender:)), for: .valueChanged)
        return datePicker
    }()
    internal lazy var activityPickerView: UIPickerView! = {
        let pickerView = UIPickerView()
        return pickerView
    }()
    internal lazy var doneButton: UIBarButtonItem! = {
        var barButton = UIBarButtonItem()
        barButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonTapped(sender:)))
        return barButton
    }()
    internal lazy var cancelButton: UIBarButtonItem! = {
        var barButton = UIBarButtonItem()
        barButton = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(cancelButtonTapped(sender:)))
        return barButton
    }()
    
}
