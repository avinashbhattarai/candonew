//
//  TeamMemberTableViewCell.swift
//  CanDo
//
//  Created by Svyat Zubyak MacBook on 06.09.16.
//  Copyright © 2016 Svyat Zubyak MacBook. All rights reserved.
//

import UIKit

class TeamMemberTableViewCell: UITableViewCell {
    @IBOutlet weak var memberAvatar: UIImageView!
    @IBOutlet weak var memberName: UILabel!
    @IBOutlet weak var prividerButton: UIButton!
    @IBOutlet weak var providerDetails: UILabel!
    @IBOutlet weak var removeFromTeamButton: UIButton!
    @IBOutlet weak var pendingInviteLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
