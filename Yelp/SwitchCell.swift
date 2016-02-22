//
//  SwitchCell.swift
//  Yelp
//
//  Created by Harpreet Singh on 2/6/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import UIKit

@objc protocol SwitchCellDelegate
{
    optional func switchCell(switchCell: SwitchCell, didChangeValue value: Bool)
}

class SwitchCell: UITableViewCell
{
    
    @IBOutlet weak var switchLabel: UILabel!
    @IBOutlet weak var onSwitch: UISwitch!
    
    weak var delegate: SwitchCellDelegate?
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        modifySwitch()
        onSwitch.addTarget(self, action: "switchValueChanged", forControlEvents: UIControlEvents.ValueChanged)
    }
    
    func switchValueChanged()
    {
            delegate?.switchCell?(self, didChangeValue: onSwitch.on)
    }

    override func setSelected(selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)
    }
    
    func modifySwitch()
    {
        onSwitch.onTintColor = UIColor(red: 156/255, green: 203/255, blue: 255/255, alpha: 1.0)
    }

}
