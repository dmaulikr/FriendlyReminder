//
//  TaskCell.swift
//  ProjectX
//
//  Created by Jonathan Chou on 4/6/16.
//  Copyright © 2016 Jonathan Chou. All rights reserved.
//

import UIKit

class TaskCell: UITableViewCell {
    @IBOutlet weak var taskDescription: UILabel!
    @IBOutlet weak var takeTask: UIButton!
    @IBOutlet weak var creator: UILabel!
    @IBOutlet weak var assignedToLabel: UILabel!
    @IBOutlet weak var assignedPeople: UILabel!
    @IBOutlet weak var checkmarkButton: UIButton!
    @IBOutlet weak var assignButton: UIButton!
}
