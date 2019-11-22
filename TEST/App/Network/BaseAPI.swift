import Foundation

/// super basic API manager for every project,never put any business logic here

let APIStatusErrorDomain = "APIStatusErrorDomain"

class BaseAPI:NSObject,URLSessionDelegate,URLSessionTaskDelegate{

    /// time out limit server not response
    static var tRequestTimeout:TimeInterval = 30.0

    // time out limit tramsimission not complete, 1 day
    var tResourceTimeout:TimeInterval = 60*60*24
    var maximumConnectionsPerHost = 20

    private var defaultHeader:[String:String] = ["content-type":"application/json"]
    var userAgent:String?

    fileprivate var operationQueue:OperationQueue?
    fileprivate var mainSession:URLSession!

// MARK: 
    override init() {
        super.init()
        
        func defaultSessionConfiguration() -> URLSessionConfiguration{
            let sessionConfig = URLSessionConfiguration.default
            
            sessionConfig.timeoutIntervalForRequest = BaseAPI.tRequestTimeout
            sessionConfig.timeoutIntervalForResource = tResourceTimeout
            sessionConfig.httpMaximumConnectionsPerHost = maximumConnectionsPerHost
            return sessionConfig
        }
        
        let myConfiguration = defaultSessionConfiguration()
        self.operationQueue = OperationQueue()
        self.mainSession = URLSession(configuration: myConfiguration, delegate:self, delegateQueue: self.operationQueue)
    }
    
    init(sessionConfiguration:URLSessionConfiguration ) {
        super.init()
        
        let myConfiguration = sessionConfiguration
        self.operationQueue = OperationQueue()
        self.mainSession = URLSession(configuration: myConfiguration, delegate:self, delegateQueue: self.operationQueue)
    }

    func resetHeader() {
        self.defaultHeader["content-type"] = "application/json"

        if let agent = userAgent {
            self.defaultHeader["User-Agent"] = agent
        }
    }

    func setHeader(_ inHeader:Dictionary<String,String>){
        self.resetHeader()

        for (key,value) in inHeader{
            self.defaultHeader[key] = value
        }
    }

    //add extra parameter into current header,override exist key
    func addHeader(_ inHeader:Dictionary<String,String>){

        for (key,value) in inHeader{
            self.defaultHeader[key] = value
        }
    }

    
}
private extension URLRequest{

    static func APIRequestWithURL(_ inURL:URL, header:[String:String] = [String:String]()) -> URLRequest{
        var request = self.init(url: inURL, cachePolicy: .useProtocolCachePolicy, timeoutInterval: BaseAPI.tRequestTimeout)
        
        var reviseHeader = header
        
        for (key,value) in header {
            reviseHeader[key] = value
        }
        
        request.allHTTPHeaderFields = reviseHeader
        
        return request
    }
    
    static func APIRequestWithURL(_ inURL:URL,_ inBody:[String:Any]?,_ header:[String:String]) -> URLRequest{
        var request = self.APIRequestWithURL(inURL, header: header)
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: inBody!, options: .prettyPrinted)
        } catch {
            
        }
        
        return request
    }

}

public enum APIMethod:String{
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"

    static let allMethods = [get, post, put, delete]
}

typealias completionHandler = (_ data:Data?,_ statusCode:Int?,_ headerField:[AnyHashable : Any]?, _ error:Error?)->Void

extension BaseAPI{
    /**
     basic func for API managment

     - parameter method:
     - parameter url:
     - parameter jsonBody:
     - parameter identifier:
     */

    func sendRequest(_ method:APIMethod,url:URL,jsonBody:Dictionary<String,Any>? = nil,identifier:String = "general",callback:@escaping completionHandler) {
        
		var request:URLRequest
		
		if let body = jsonBody {
            request = URLRequest.APIRequestWithURL(url, body, self.defaultHeader)
		} else{
			request = URLRequest.APIRequestWithURL(url, header: self.defaultHeader)
		}
		
		request.httpMethod = method.rawValue
		
		let handler:(Data?,URLResponse?,Error?) -> Void = {data,response,error in
			// api cancel,must because another API is processing
			if  error?._code == NSURLErrorCancelled {
				return
			}
			
			guard data != nil, error == nil else {
				print("Error: did not receive data")
				DispatchQueue.main.async{
                    self.showLog(url, data)
                    callback(data,nil,nil,error)
				}
				return
			}
			
            var resultError:Error? = error
			var statusCode = 404
            var header = [AnyHashable:Any]()
            
			if let httpResponse = (response as? HTTPURLResponse){
				statusCode = httpResponse.statusCode
                header = httpResponse.allHeaderFields
			}
            
            if ![200,201,202,203,204,205,206,207,208,226].contains(statusCode) {
                var userInfo: [String:Any] = [:]
                if let data = data {
                    let raw = String(data: data, encoding: .utf8)
                    if let raw = raw {
                        userInfo["raw"] = raw
                    }
                }
                userInfo["statusCode"] = statusCode
                resultError = NSError(domain: APIStatusErrorDomain, code: statusCode, userInfo: userInfo)
            }
            
            DispatchQueue.main.async{
                self.showLog(url, data)
                callback(data,statusCode,header,resultError)
            }
	
			
		}
		
		let task = mainSession.dataTask(with: request as URLRequest, completionHandler: handler)
		
		task.taskDescription = identifier
		
		task.resume()
	}
    
    private func showLog(_ url:URL, _ data:Data?){
        if let data = data, let str = String(data: data, encoding: .utf8) {
//            print(str)
        }
    }
	

    func cancelRequest(_ identifier:String,callback:(()->Void)?){
		
        mainSession.getTasksWithCompletionHandler({ (dataTask, uploadTask, downloadTask) -> Void in
			
            let allTasks = NSArray(array: dataTask)
            allTasks.addingObjects(from: uploadTask)
            allTasks.addingObjects(from: downloadTask)
			
            if allTasks.count > 0{
                for task:URLSessionTask in allTasks as! [URLSessionDataTask]{
                    if task.taskDescription == identifier{
                        task.cancel()
                    }
                }
            }
			
            if callback != nil{
                DispatchQueue.main.async{
                    callback!()
                }
            }
        })
    }
    
    func downloadTest(_ method:APIMethod,url:URL,identifier:String = "downloadTest", callback:@escaping(_ data:Data?, _ duration: TimeInterval,_ statusCode:Int?,_ headerField:[AnyHashable : Any]?, _ error:Error?)->Void) {
        let startTime = DispatchTime.now()
        
        var request = URLRequest.APIRequestWithURL(url)
        
        request.httpMethod = APIMethod.get.rawValue
        
        let handler:(Data?,URLResponse?,Error?) -> Void = {data,response,error in
            // api cancel,must because another API is processing
            if  error?._code == NSURLErrorCancelled {
                return
            }
            
            guard data != nil, error == nil else {
                print("Error: did not receive data")
                let endTime = DispatchTime.now()
                let duration = TimeInterval( (endTime.uptimeNanoseconds - startTime.uptimeNanoseconds) / 1000000000 )
                DispatchQueue.main.async{
                    self.showLog(url, data)
                    callback(data, duration, nil,nil,error)
                }
                return
            }
            
            var resultError:Error? = error
            var statusCode = 404
            var header = [AnyHashable:Any]()
            
            if let httpResponse = (response as? HTTPURLResponse){
                statusCode = httpResponse.statusCode
                header = httpResponse.allHeaderFields
            }
            
            if ![200,201,202,203,204,205,206,207,208,226].contains(statusCode) {
                var userInfo: [String:Any] = [:]
                if let data = data {
                    let raw = String(data: data, encoding: .utf8)
                    if let raw = raw {
                        userInfo["raw"] = raw
                    }
                }
                userInfo["statusCode"] = statusCode
                resultError = NSError(domain: APIStatusErrorDomain, code: statusCode, userInfo:userInfo)
            }
            
            let endTime = DispatchTime.now()
            //                let duration = TimeInterval( (endTime.uptimeNanoseconds - startTime.uptimeNanoseconds) / 1000000000 )
            let nanoTime = endTime.uptimeNanoseconds - startTime.uptimeNanoseconds
            let timeInterval = Double(nanoTime) / 1_000_000_000
            DispatchQueue.main.async{
                self.showLog(url, data)
                print("Time: \(timeInterval) seconds")
                callback(data, timeInterval, statusCode,header,resultError)
            }
            
            
        }
        
        let task = mainSession.dataTask(with: request as URLRequest, completionHandler: handler)
        task.taskDescription = identifier
        task.resume()
    }
}

protocol URLQueryParameterStringConvertible {
    var queryParameters: String {get}
}

extension Dictionary : URLQueryParameterStringConvertible {
    /**
     This computed property returns a query parameters string from the given NSDictionary. For
     example, if the input is @{@"day":@"Tuesday", @"month":@"January"}, the output
     string will be @"day=Tuesday&month=January".
     @return The computed parameters string.
     */
    var queryParameters: String {
        var parts: [String] = []
        for (key, value) in self {
            let part = NSString(format: "%@=%@",
                                String(describing: key).addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!,
                                String(describing: value).addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)
            parts.append(part as String)
        }
        return parts.joined(separator: "&")
    }
    
}

extension URL {
    /**
     Creates a new URL by adding the given query parameters.
     @param parametersDictionary The query parameter dictionary to add.
     @return A new NSURL.
     */
    func URLByAppendingQueryParameters(_ parametersDictionary : Dictionary<String, String>) -> URL {
        let URLString : NSString = NSString(format: "%@?%@", self.absoluteString, parametersDictionary.queryParameters)
        return URL(string: URLString as String)!
    }
}
