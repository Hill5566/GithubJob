
import UIKit
import Kingfisher

class ViewController: UIViewController {

    let viewModel = ViewControllerViewModel()
    @IBOutlet weak var mTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.getUsers {[weak self] in
            self?.mTableView.reloadData()
        }
    }
}


extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.users.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 86
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        let user = viewModel.users[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: user.site_admin ?? false ? "AdminCell":"Cell") as! UserTableViewCell
        cell.set(user: user)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = viewModel.users[indexPath.row]
        viewModel.toDetailVC(user: user, fromVC: self)
    }
}

class UserTableViewCell: UITableViewCell {
    @IBOutlet weak var avatar:UIImageView?
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var adminLabel: UILabel! {
        didSet {
            adminLabel.layer.cornerRadius = adminLabel.frame.height/2
        }
    }
    
    func set(user:User) {
        self.avatar?.setImageAsyncFrom(urlString: user.avatar_url ?? "")
        self.name.text = user.login
    }
}

struct User: Codable {
    let login: String?
    let avatar_url: String?
    let site_admin: Bool?
}
