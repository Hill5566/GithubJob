//
//  DetailVC.swift
//  App
//
//  Created by Hill Lin on 2019/11/22.
//  Copyright © 2019 Hill. All rights reserved.
//

import UIKit

class DetailVC: UIViewController {

    static func fromStoryBoard() -> DetailVC {
        return (UIStoryboard.init(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: String(describing: DetailVC.self)) as! DetailVC)
    }

    @IBAction func close(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var loginLabel: UILabel!
    @IBOutlet weak var side_adminLabel: UILabel!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var blogLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        avatar.setImageAsyncFrom(urlString: user.avatar_url)
//        name.text = user.name
//        loginLabel.text = user.login
//        blogLabel.text = user.blog
    }
    

  
    

}
