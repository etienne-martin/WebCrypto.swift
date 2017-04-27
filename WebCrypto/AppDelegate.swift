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
        
        let password = "awdawdawdawd"
        let stringSample = Data("Nullam quis risus eget urna mollis ornare vel eu leo.".utf8)
        
        crypto.encrypt(data: stringSample, password: password, callback: {(encrypted: Data?, error: Error?) in
            crypto.decrypt(data: encrypted!, password: password, callback: {(decrypted: Data?, error: Error?) in
                if decrypted! == stringSample {
                    print("Password-based encryption: success")
                }else{
                    print("Fail")
                }
            })
        })
        
        let key = "6f0f1c6f0e56afd327ff07b7b63a2d8ae91ab0a2f0c8cd6889c0fc1d624ac1b8"
        let iv = "92c9d2c07a9f2e0a0d20710270047ea2"
        
        crypto.encrypt(data: stringSample, key: key, iv: iv, callback: {(encrypted: Data?, error: Error?) in
            crypto.decrypt(data: encrypted!, key: key, iv: iv, callback: {(decrypted: Data?, error: Error?) in
                if decrypted! == stringSample {
                    print("Key-based encryption: success")
                }else{
                    print("Fail")
                }
            })
        })
        
        /*
        
        // AES file encryption

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
 
        */
        
        // Hashing functions
        
        crypto.sha1(data: stringSample, callback: {(hash: String?, error: Error?) in
            if( hash! == "fe2aa35f4fcb32ae2245b48d8bd814eb261a977c" ){
                print("SHA1: success")
            }else{
                print("Fail")
            }
        })
        
        crypto.sha256(data: stringSample, callback: {(hash: String?, error: Error?) in
            if( hash! == "0427da5c514a96f4121ca458ea805d20c3f89c84a025ec8c35a5ff6af26cdce9" ){
                print("SHA256: success")
            }else{
                print("Fail")
            }
        })
        
        crypto.sha384(data: stringSample, callback: {(hash: String?, error: Error?) in
            if( hash! == "de7c12a48cddba478cb5225266a555565332d2e0aa954023467118644f5ebab0264962c8138a9597794db02e48c9928e" ){
                print("SHA384: success")
            }else{
                print("Fail")
            }
        })
        
        crypto.sha512(data: stringSample, callback: {(hash: String?, error: Error?) in
            if( hash! == "72cfbd33938d7671ea1c91598d8592b76f0c3b94185baf951d651a56b75ceec8a9d6563a1614c5524538ead6fa1d52b24c726a8ca16300767bc2f71fa8325ddb" ){
                print("SHA512: success")
            }else{
                print("Fail")
            }
        })
        
        // Data conversion
        
        let dataKey = Data(bytes: [0, 1, 127, 128, 255, 0, 1, 127, 128, 255, 0, 1, 127, 128, 255, 3])
        
        if dataKey == crypto.dataFromHexEncodedString(crypto.hexEncodedString(dataKey)) {
            print("Hexadecimal data conversion: success")
        }
        
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
