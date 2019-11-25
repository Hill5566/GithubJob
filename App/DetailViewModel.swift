//
//  DetailViewModel.swift
//  App
//
//  Created by Hill Lin on 2019/11/25.
//  Copyright © 2019 Hill. All rights reserved.
//

import UIKit

class DetailViewModel: NSObject {
    
    public var user: User?
       
    public func getUser(completionBlock:@escaping(UserDetail)->()) {
        API.getUserDetail(name: user?.login ?? "") { (user) in
            completionBlock(user)
        }
    }
}
