//
//  AppDelegate.swift
//  WebCrypto
//
//  Created by emartin on 2017-04-13.
//  Copyright © 2017 etiennemartin.ca. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
        let password = "awdawdawdawd"
        let crypto = WebCrypto()
        
        crypto.generateKey(callback: {(key: String?, error: Error?) in
            print("Key:", key!)
        })
        crypto.generateKey(length: 192, callback: {(key: String?, error: Error?) in
            print("Key:", key!)
        })
        crypto.generateKey(length: 128, callback: {(key: String?, error: Error?) in
            print("Key:", key!)
        })
        
        crypto.generateIv(callback: {(iv: String?, error: Error?) in
            print("Iv:", iv!)
        })
        
        crypto.generateRandomNumber(length: 16, callback: {(number: String?, error: Error?) in
            print("Random number:", number!)
        })
        
        // AES string encryption
        let stringSample = "Nullam quis risus eget urna mollis ornare vel eu leo."
        crypto.encrypt(data: Data(stringSample.utf8), password: password, callback: {(encrypted: Data?, error: Error?) in
            crypto.decrypt(data: encrypted!, password: password, callback: {(decrypted: Data?, error: Error?) in
                if String(data: decrypted!, encoding: .utf8)! == stringSample {
                    print("String successfully encrypted & decrypted (Password-based)")
                }else{
                    print("Fail")
                }
            })
        })
        
        crypto.encrypt(data: Data(stringSample.utf8), key: "6f0f1c6f0e56afd327ff07b7b63a2d8ae91ab0a2f0c8cd6889c0fc1d624ac1b8", iv: "92c9d2c07a9f2e0a0d20710270047ea2", callback: {(encrypted: Data?, error: Error?) in
            crypto.decrypt(data: encrypted!, key: "6f0f1c6f0e56afd327ff07b7b63a2d8ae91ab0a2f0c8cd6889c0fc1d624ac1b8", iv: "92c9d2c07a9f2e0a0d20710270047ea2", callback: {(decrypted: Data?, error: Error?) in
                if String(data: decrypted!, encoding: .utf8)! == stringSample {
                    print("String successfully encrypted & decrypted (Key-based)")
                }else{
                    print("Fail")
                }
            })
        })
        
        /*
         
         // AES file encryption
         
         crypto.generateKey(callback: {(key: String?, error: Error?) in
         print("Key:", key!)
         
         do{
         // Load file from disk
         let sampleFileData = try Data(contentsOf: URL(string: "file:///var/tmp")!.appendingPathComponent("test10Mb.db"))
         
         let start = Date().timestamp()
         
         crypto.encrypt(data: sampleFileData, password: password, callback: {(encrypted: Data?, error: Error?) in
         
         print(Date().timestamp()-start)
         
         crypto.decrypt(data: encrypted!, password: password, callback: {(decrypted: Data?, error: Error?) in
         
         if decrypted! == sampleFileData {
         print("File successfully encrypted & decrypted")
         }else{
         print("Fail")
         }
         })
         })
         }catch(let error){
         print(error)
         }
         
         })
         
         */
        
        // Hashing functions
        
        crypto.sha1(data: Data("awkjdhawdkjawhdk".utf8), callback: {(hash: String?, error: Error?) in
            print("SHA1:", hash!)
        })
        
        crypto.sha256(data: Data("awkjdhawdkjawhdk".utf8), callback: {(hash: String?, error: Error?) in
            print("SHA256:", hash!)
        })
        
        crypto.sha384(data: Data("awkjdhawdkjawhdk".utf8), callback: {(hash: String?, error: Error?) in
            print("SHA384:", hash!)
        })
        
        crypto.sha512(data: Data("awkjdhawdkjawhdk".utf8), callback: {(hash: String?, error: Error?) in
            print("SHA512:", hash!)
        })
        
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
}

extension Date {
    func timestamp() -> Int64 {
        return Int64(self.timeIntervalSince1970 * 1000)
    }
}
