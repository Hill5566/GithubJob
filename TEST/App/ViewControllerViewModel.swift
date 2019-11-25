

import UIKit

class ViewControllerViewModel {
    
    public var users: [User] = []
    
    public func getUsers(completionBlock:@escaping()->()) {
        API.getUser { (users) in
            self.users = users
            completionBlock()
        }
    }
    
    public func toDetailVC(user:User, fromVC:UIViewController) {
        let vc = DetailVC.fromStoryBoard()
        vc.modalPresentationStyle = .fullScreen
        vc.viewModel.user = user
        fromVC.present(vc, animated: true, completion: nil)
    }
}

