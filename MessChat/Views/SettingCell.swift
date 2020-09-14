//
// SettingCell.swift
// MessChat
//
// Created by GIABAO Photography on 9/9/20.
// Copyright © 2020 GIABAO Photography. All rights reserved.
// VAN HIEN University 
//
// Website: https://giabaophoto.com
// 
// 


import UIKit

class SettingCell: UITableViewCell {
    
    lazy var switchControl: UISwitch = {
       let switchControl = UISwitch()
        switchControl.isOn = true
        switchControl.onTintColor = .link
        switchControl.translatesAutoresizingMaskIntoConstraints = false
        switchControl.addTarget(self, action: #selector(handSwitchAction), for: .valueChanged)
        return switchControl
    }()
    
    var sectionType: SectionType? {
        didSet{
            guard let sectionType = sectionType else {
                return
            }
            textLabel?.text = sectionType.description
            switchControl.isHidden = !sectionType.containsSwitch
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?){
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        sv(
            switchControl
        )
        switchControl.centerVertically()
        switchControl.right(16)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func handSwitchAction(sender: UISwitch){
        if sender.isOn {
            print("ON")
        }
        else{
            print("OFF")
        }
    }
}
