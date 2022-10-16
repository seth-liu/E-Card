//
//  UserCell.swift
//  ECard
//
//  Created by David Lin on 2022-09-12.
//

import UIKit
import RealmSwift

class UserCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profilePictureView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        profilePictureView.makeRounded()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func loadImage(imageID: ObjectId) {
        if (!imageID.isEqual(ObjectId())) {
            ImageProcessor.getImage(imageID: imageID, imageView: profilePictureView)
        }
    }
}
