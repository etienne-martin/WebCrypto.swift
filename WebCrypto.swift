//
//  WebCrypto.swift
//  WebCrypto
//
//  Created by emartin on 2017-04-02.
//  Copyright © 2017 etiennemartin.ca. All rights reserved.
//

import WebKit

private func loadJsFile( _ filename: String) -> String? {
    let jsPath = Bundle.main.path(forResource: filename, ofType: "js")
    if let jsFilePath = jsPath {
        do{
            let js = try String(contentsOfFile: jsFilePath, encoding: String.Encoding.utf8)
            return js
        }catch{
            return nil
        }
    }
    return nil
}

open class WebCrypto: NSObject, WKScriptMessageHandler{
    
    public enum Error: Swift.Error {
        /// Unknown
        case unknown
    }
    
    var webView:WKWebView
    var callbackIndex:Int = 0
    var dataCallbacks: [String : (Data?, WebCrypto.Error?) -> ()] = [:]
    var stringCallbacks: [String : (String?, WebCrypto.Error?) -> ()] = [:]
    
    private func registerDataCallback( _ callback: @escaping (Data?, WebCrypto.Error?) -> ()){
        callbackIndex += 1
        dataCallbacks["\(callbackIndex)"] = callback
    }
    private func registerStringCallback( _ callback: @escaping (String?, WebCrypto.Error?) -> ()){
        callbackIndex += 1
        stringCallbacks["\(callbackIndex)"] = callback
    }
    
    override init(){
        
        webView = WKWebView(frame: .zero)
        super.init()
        
        let js = loadJsFile("WebCrypto")
        if let jsFile = js {
            
            // Escape the javascript file before injecting it in the webview
            // http://stackoverflow.com/questions/11478324/syntaxerror-unexpected-eof-when-evaluating-javascript-in-ios-uiwebview
            //jsFile = jsFile.replacingOccurrences(of: "\\'", with: "\\\'")
            //jsFile = jsFile.replacingOccurrences(of: "\\\"", with: "\\\\\"")
            //jsFile = jsFile.replacingOccurrences(of: "\\r", with: "\\n")
            //jsFile = jsFile.replacingOccurrences(of: "\\n", with: "\\\n")
            
            webView.evaluate(script: jsFile, completion: { (result, error) in
                if let errorMessage = error {
                    print(errorMessage)
                }else{
                    self.webView.configuration.userContentController.add(self, name: "scriptHandler")
                    
                    self.webView.evaluateJavaScript("init()") { (result, error) in
                        if let errorMessage = error {
                            print(errorMessage)
                        }
                    }
                }
            })
        }else{
            print("fail")
        }
    }
    
    // [ Callback handler ]
    
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage){
        if let dict = message.body as? Dictionary<String, AnyObject> {
            
            let index = dict["callback"]!
            let result = dict["result"]
            let error = dict["error"]
            let function = dict["func"]!
            
            switch("\(function)"){
                case "data":
                    
                    let callback = dataCallbacks["\(index)"]!
                    
                    // Deregister the callback
                    dataCallbacks["\(index)"] = nil
                    
                    if error != nil {
                        callback(nil, Error.unknown)
                        return;
                    }
                
                    if let unwrappedResult = result {
                        if let data = Data(base64Encoded: "\(unwrappedResult)", options: .ignoreUnknownCharacters) {
                            callback(data, nil)
                        }else{
                            print("Unable to decode the data")
                            callback(nil, Error.unknown)
                        }
                    }
                
                case "string":
                    
                    let callback = stringCallbacks["\(index)"]!
                    
                    // Deregister the callback
                    stringCallbacks["\(index)"] = nil
                    
                    if error != nil {
                        callback(nil, Error.unknown)
                        return;
                    }
                    
                    if let unwrappedResult = result {
                        if let data = Data(base64Encoded: "\(unwrappedResult)", options: .ignoreUnknownCharacters) {
                            
                            if let hash = String(data: data, encoding: .utf8) {
                                callback(hash, nil)
                            }
                            
                        }else{
                            print("Unable to decode the data")
                            callback(nil, Error.unknown)
                        }
                    }
                
                default: break
            }
        }
    }
    
    // [ AES functions ]
    
    open func encrypt(data: Data, password: String, callback: @escaping (Data?, WebCrypto.Error?) -> ()){
        aes(action: "encrypt", data: data, password: password, key: nil, iv: nil, callback: callback)
    }
    open func encrypt(data: Data, key: String, iv: String, callback: @escaping (Data?, WebCrypto.Error?) -> ()){
        aes(action: "encrypt", data: data, password: nil, key: key, iv: iv, callback: callback)
    }
    open func decrypt(data: Data, password: String, callback: @escaping (Data?, WebCrypto.Error?) -> ()){
        aes(action: "decrypt", data: data, password: password, key: nil, iv: nil, callback: callback)
    }
    open func decrypt(data: Data, key: String, iv: String, callback: @escaping (Data?, WebCrypto.Error?) -> ()){
        aes(action: "decrypt", data: data, password: nil, key: key, iv: iv, callback: callback)
    }
    
    private func aes(action: String, data: Data, password: String?, key: String?, iv: String?, callback: @escaping (Data?, WebCrypto.Error?) -> ()){
        
        let base64Data = data.base64EncodedString(options: [])
        
        registerDataCallback(callback)
        
        var secret = ""
        
        if let unwrappedPassword = password {
            secret = "password: '\(unwrappedPassword)'"
        }
        
        if let unwrappedKey = key {
            secret = "key: '\(unwrappedKey)', iv: '\(iv!)'"
        }
        
        webView.evaluateJavaScript("WebCrypto.\(action)({data: '\(base64Data)', \(secret), callback: \(callbackIndex)})") { (result, error) in
            if let errorMessage = error {
                print(errorMessage)
            }
        }
    }
    
    open func generateRandomNumber(length:Int, callback: @escaping (String?, WebCrypto.Error?) -> ()){
        registerStringCallback(callback)
        webView.evaluateJavaScript("WebCrypto.generateRandomNumber({length: \(length), callback: \(callbackIndex)})") { (result, error) in
            if let errorMessage = error {
                print(errorMessage)
            }
        }
    }
    
    open func generateKey(length:Int = 256, callback: @escaping (String?, WebCrypto.Error?) -> ()){
        registerStringCallback(callback)
        webView.evaluateJavaScript("WebCrypto.generateKey({length: \(length), callback: \(callbackIndex)})") { (result, error) in
            if let errorMessage = error {
                print(errorMessage)
            }
        }
    }
    
    open func generateIv(callback: @escaping (String?, WebCrypto.Error?) -> ()){
        registerStringCallback(callback)
        webView.evaluateJavaScript("WebCrypto.generateIv({callback: \(callbackIndex)})") { (result, error) in
            if let errorMessage = error {
                print(errorMessage)
            }
        }
    }
    
    // [ Hashing functions ]
    
    open func sha1(data: Data, callback: @escaping (String?, WebCrypto.Error?) -> ()){
        hash(data: data, algorithm: "SHA-1", callback: callback)
    }
    open func sha256(data: Data, callback: @escaping (String?, WebCrypto.Error?) -> ()){
        hash(data: data, algorithm: "SHA-256", callback: callback)
    }
    open func sha384(data: Data, callback: @escaping (String?, WebCrypto.Error?) -> ()){
        hash(data: data, algorithm: "SHA-384", callback: callback)
    }
    open func sha512(data: Data, callback: @escaping (String?, WebCrypto.Error?) -> ()){
        hash(data: data, algorithm: "SHA-512", callback: callback)
    }
    
    private func hash(data: Data, algorithm: String, callback: @escaping (String?, WebCrypto.Error?) -> ()){
        
        let base64Data = data.base64EncodedString(options: [])
        
        registerStringCallback(callback)
        
        webView.evaluateJavaScript("WebCrypto.hash({data: '\(base64Data)', algorithm: '\(algorithm)', callback: \(callbackIndex)})") { (result, error) in
            if let errorMessage = error {
                print(errorMessage)
            }
        }
    }
}

private extension WKWebView {
    func evaluate(script: String, completion: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) {
        var finished = false
        
        evaluateJavaScript(script) { (result, error) in
            if error == nil {
                if result != nil {
                    completion(result as AnyObject?, nil)
                }
            } else {
                completion(nil, error as NSError?)
            }
            finished = true
        }
        
        while !finished {
            RunLoop.current.run(mode: .defaultRunLoopMode, before: Date.distantFuture)
        }
    }
}
