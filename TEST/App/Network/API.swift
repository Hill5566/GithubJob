
import Foundation

var API:APIManager {
    return APIManager.default
}

class APIManager {
    static let `default` = APIManager()
    
    func getUser(completionBlock:@escaping([User])->()) {
        URLSession.shared.dataTask(with: URL(string: "https://api.github.com/users?page=0&per_page=100")!) { data, response, error in
            if let data = data {
                do {
                    let res = try JSONDecoder().decode([User].self, from: data)
                    print(res)
                    DispatchQueue.main.async {
                        completionBlock(res)
                    }
                    
                } catch let error {
                    print(error)
                }
            }
        }.resume()
    }
    func getUserDetail(name:String, completionBlock:@escaping(UserDetail)->()) {
         URLSession.shared.dataTask(with: URL(string: "https://api.github.com/users/\(name)")!) { data, response, error in
             if let data = data {
                 do {
                     let res = try JSONDecoder().decode(UserDetail.self, from: data)
                     print(res)
                     DispatchQueue.main.async {
                         completionBlock(res)
                     }
                     
                 } catch let error {
                     print(error)
                 }
             }
         }.resume()
     }
}



