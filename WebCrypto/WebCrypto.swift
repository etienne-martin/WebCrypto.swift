/*

MIT License

Copyright (c) 2017 Etienne Martin

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

*/

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
        // JavaScript exception
        case javaScriptException
        // Invalid password length
        case invalidPasswordLength
        // Invalid key length
        case invalidKeyLength
        // Invalid IV length
        case invalidIvLength
        // Unknown
        case unknown
    }
    
    var webView:WKWebView
    var callbackIndex:Int = 0
    var dataCallbacks: [String : (Data?, WebCrypto.Error?) -> ()] = [:]
    var stringCallbacks: [String : (String?, WebCrypto.Error?) -> ()] = [:]
    
    private func registerDataCallback( _ callback: @escaping (Data?, WebCrypto.Error?) -> ()) -> Int {
        callbackIndex += 1
        dataCallbacks["\(callbackIndex)"] = callback
        return callbackIndex
    }
    private func registerStringCallback( _ callback: @escaping (String?, WebCrypto.Error?) -> ()) -> Int {
        callbackIndex += 1
        stringCallbacks["\(callbackIndex)"] = callback
        return callbackIndex
    }
    
    private func convertErrorCode( _ errorCode: String) -> Error {
        switch(errorCode){
            case "javaScriptException":
                return Error.javaScriptException
            case "invalidPasswordLength":
                return Error.invalidPasswordLength
            case "invalidKeyLength":
                return Error.invalidKeyLength
            case "invalidIvLength":
                return Error.invalidIvLength
            default:
                return Error.unknown
        }
    }
    
    override init(){
        
        webView = WKWebView(frame: .zero)
        super.init()
        
        let initializationErrorMessage = "Unable to load WebCrypto.js"
        
        let js = loadJsFile("WebCrypto")
        if let jsFile = js {
            webView.evaluate(script: jsFile, completion: { (result, error) in
                if let errorMessage = error {
                    print(initializationErrorMessage)
                    print(errorMessage)
                }else{
                    self.webView.configuration.userContentController.add(self, name: "scriptHandler")
                    self.webView.evaluateJavaScript("initWebCrypto()") { (result, error) in
                        if let errorMessage = error {
                            print(initializationErrorMessage)
                            print(errorMessage)
                        }
                    }
                }
            })
        }else{
            // WebCrypto.js couldn't be found
            print(initializationErrorMessage)
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
                    
                    if let errorCode = error {
                        callback(nil, convertErrorCode("\(errorCode)"))
                        return;
                    }
                
                    if let unwrappedResult = result {
                        if let data = Data(base64Encoded: "\(unwrappedResult)", options: .ignoreUnknownCharacters) {
                            callback(data, nil)
                        }else{
                            // Unable to decode the base64 data
                            callback(nil, Error.unknown)
                        }
                    }
                
                case "string":
                    
                    let callback = stringCallbacks["\(index)"]!
                    
                    // Deregister the callback
                    stringCallbacks["\(index)"] = nil
                    
                    if let errorCode = error {
                        callback(nil, convertErrorCode("\(errorCode)"))
                        return;
                    }
                    
                    if let string = result {
                        callback("\(string)", nil)
                    }else{
                        // The result is empty
                        callback(nil, Error.unknown)
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
        let index = registerDataCallback(callback)
        var secret = ""
        
        if let unwrappedPassword = password {
            secret = "password: '\(unwrappedPassword)'"
        }else if let unwrappedKey = key {
            secret = "key: '\(unwrappedKey)', iv: '\(iv!)'"
        }
        
        webView.evaluateJavaScript("WebCrypto.\(action)({data: '\(base64Data)', \(secret), callback: \(index)})") { (result, error) in
            if error != nil {
                // Deregister the callback
                self.dataCallbacks["\(index)"] = nil
                callback(nil, Error.javaScriptException)
            }
        }
    }
    
    open func generateKey(length:Int = 256, callback: @escaping (String?, WebCrypto.Error?) -> ()){
        let index = registerStringCallback(callback)
        webView.evaluateJavaScript("WebCrypto.generateKey({length: \(length), callback: \(index)})") { (result, error) in
            if error != nil {
                // Deregister the callback
                self.stringCallbacks["\(index)"] = nil
                callback(nil, Error.javaScriptException)
            }
        }
    }
    open func generateRandomNumber(length:Int, callback: @escaping (String?, WebCrypto.Error?) -> ()){
        let index = registerStringCallback(callback)
        webView.evaluateJavaScript("WebCrypto.generateRandomNumber({length: \(length), callback: \(index)})") { (result, error) in
            if error != nil {
                // Deregister the callback
                self.stringCallbacks["\(index)"] = nil
                callback(nil, Error.javaScriptException)
            }
        }
    }
    open func generateIv(callback: @escaping (String?, WebCrypto.Error?) -> ()){
        generateRandomNumber(length: 16, callback: callback)
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
        let index = registerStringCallback(callback)
        webView.evaluateJavaScript("WebCrypto.hash({data: '\(base64Data)', algorithm: '\(algorithm)', callback: \(index)})") { (result, error) in
            if error != nil {
                // Deregister the callback
                self.stringCallbacks["\(index)"] = nil
                callback(nil, Error.javaScriptException)
            }
        }
    }
    
    // Data conversion functions (Helpers)
    
    open func hexEncodedStringFromData( _ data:Data) -> String {
        return data.map { String(format: "%02hhx", $0) }.joined()
    }
    
    open func dataFromHexEncodedString( _ hex: String) -> Data {
        var hex = hex
        var data = Data()
        while(hex.characters.count > 0) {
            let c: String = hex.substring(to: hex.index(hex.startIndex, offsetBy: 2))
            hex = hex.substring(from: hex.index(hex.startIndex, offsetBy: 2))
            var ch: UInt32 = 0
            Scanner(string: c).scanHexInt32(&ch)
            var char = UInt8(ch)
            data.append(&char, count: 1)
        }
        return data
    }
    
}

private extension WKWebView{
    func evaluate(script: String, completion: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void){
        var finished = false
        evaluateJavaScript(script){( result, error ) in
            if error == nil {
                if result != nil {
                    completion(result as AnyObject?, nil)
                }
            }else{
                completion(nil, error as NSError?)
            }
            finished = true
        }
        while !finished{
            RunLoop.current.run(mode: .defaultRunLoopMode, before: Date.distantFuture)
        }
    }
}
