//
//  DetailVC.swift
//  App
//
//  Created by Hill Lin on 2019/11/22.
//  Copyright © 2019 Hill. All rights reserved.
//

import UIKit

class DetailVC: UIViewController {

    var viewModel = DetailViewModel()
    
    static func fromStoryBoard() -> DetailVC {
        return (UIStoryboard.init(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: String(describing: DetailVC.self)) as! DetailVC)
    }

    @IBAction func close(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    @IBOutlet weak var avatar: UIImageView! {
        didSet {
            avatar.layer.cornerRadius = avatar.frame.width/2
        }
    }
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var bioLabel: UILabel!
    @IBOutlet weak var loginLabel: UILabel!
    @IBOutlet weak var loginLabelHConstraint: NSLayoutConstraint!
    @IBOutlet weak var side_adminLabel: UILabel! {
        didSet {
            side_adminLabel.layer.cornerRadius = side_adminLabel.frame.height/2
        }
    }
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var blogLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.getUser { user in
            self.avatar.setImageAsyncFrom(urlString: user.avatar_url ?? "")
            self.name.text = user.name
            self.bioLabel.text = user.bio
            self.loginLabel.text = user.login
            self.side_adminLabel.isHidden = user.site_admin ?? false ? false : true
            if user.site_admin ?? false {
                _ = self.loginLabelHConstraint.setMultiplier(multiplier: 1.03)
                
            }
            self.location.text = user.location
            self.blogLabel.text = user.blog
        }
    }

}

struct UserDetail: Codable {
    let login: String?
    let name: String?
    let location: String?
    let blog: String?
    let bio: String?
    let avatar_url: String?
    let site_admin: Bool?
}
extension NSLayoutConstraint {
    /**
     Change multiplier constraint

     - parameter multiplier: CGFloat
     - returns: NSLayoutConstraint
    */
    func setMultiplier(multiplier:CGFloat) -> NSLayoutConstraint {

        NSLayoutConstraint.deactivate([self])

        let newConstraint = NSLayoutConstraint(
            item: firstItem,
            attribute: firstAttribute,
            relatedBy: relation,
            toItem: secondItem,
            attribute: secondAttribute,
            multiplier: multiplier,
            constant: constant)

        newConstraint.priority = priority
        newConstraint.shouldBeArchived = self.shouldBeArchived
        newConstraint.identifier = self.identifier

        NSLayoutConstraint.activate([newConstraint])
        return newConstraint
    }
}
