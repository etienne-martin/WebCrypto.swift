# WebCrypto.swift

A small collection of cryptographic functions based on the javascript WebCrypto API. Allows you to share the same crypto between a native iOS/OSX application and a web application.

### The story

The original [CryptoJS.swift](https://github.com/etienne-martin/CryptoJS.swift) library was developed in 2015 as I needed a way to share the same cryptography between a swift application and a web app. My goal was achieved by using the same javascript [CryptoJS library](https://github.com/brix/crypto-js) in both environments. CryptoJS now suffers severe performance limitations over the new [WebCrypto API](https://developer.mozilla.org/en-US/docs/Web/API/Web_Crypto_API). 

This project leverages the power of the WebCrypto API while keeping backwards compatiblity with CryptoJS.swift. All methods are asynchronous and run on a separate thread. 

## Performance

In comparison with other available solutions, here are the results obtained when encrypting a 10MB file with AES-256 on a 2.6 GHz Intel Core i7.
 
**WebCrypto.swift:** 1545ms  
**CryptoSwift:**     24366ms  
**openSSL:**         139ms

## Usage 

1. Drag and drop [WebCrypto.swift](http://adawd.cawd) and [WebCrypto.js](http://adawd.cawd) into your Xcode project.  
2. Initialize the WebCrypto class in your code.

```swift
let crypto = WebCrypto()
```

3. That's it.

#### Data types conversion

WebCrypto.swift works with swift's Data() type. If you need to pass a string to a method, you need to convert it to Data() before passing it as an input. 

Convert string to data:

```swift
let data = Data("This is a string".utf8)
```

Convert data to string:

```swift
let string = String(data: data, encoding: .utf8)
```

## AES

Cipher-block chaining (CBC) mode

### Password-based encryption

This is a paragraph explaining that WebCrypto.swift uses the same password derivation as openssl.

###### Encryption

```swift
let input = Data("This is a string".utf8)

let password = "password123"

crypto.encrypt(data: input, password: password, callback: {(encrypted: Data?, error: Error?) in
    print(encrypted!)
})
```
###### Decryption

```swift
crypto.decrypt(data: encrypted, password: password, callback: {(decrypted: Data?, error: Error?) in
    print(String(data: decrypted!, encoding: .utf8)!)
})
```
### Key-based encryption

Accepts hex-encoded key and IV.

###### Encryption

```swift
let input = Data("This is a string".utf8)

let key = "6f0f1c6f0e56afd327ff07b7b63a2d8ae91ab0a2f0c8cd6889c0fc1d624ac1b8"
let iv = "92c9d2c07a9f2e0a0d20710270047ea2"

crypto.encrypt(data: input, key: key, iv: iv, callback: {(encrypted: Data?, error: Error?) in
    print(encrypted!)
})
```

###### Decryption

```swift
crypto.decrypt(data: encrypted, key: key, iv: iv, callback: {(encrypted: Data?, error: Error?) in
    print(String(data: decrypted!, encoding: .utf8)!)
})
```

## Encryption keys

This method generates keys with lengths of 128, 192 or 256. If the length parameter is omitted, the ouput is a 256 bits key by default.

```swift
crypto.generateKey(callback: {(key: String?, error: Error?) in
    print(key!) // aacdc64d6a3f88617af1ce43666970f0e915372cadda8ecb992d215b282a8c17
})

crypto.generateKey(length: 192, callback: {(key: String?, error: Error?) in
    print(key!) // 8c675b785838af61c4803c84fe3ba858a4556bdfcafc6c33
})

crypto.generateKey(length: 128, callback: {(key: String?, error: Error?) in
    print(key!) // dc1afda2e1bc5f9bd513a658b853cdec
})
```

## Initialization vectors

This method generates a 16 bits hex-encoded IV. Remember to never re-use an initialization vectors. Always generate a new IV every time your encrypt.

```swift
crypto.generateIv(callback: {(iv: String?, error: Error?) in
    print(iv!) // a408350a6ef6ceb8883173778d700b0a
})
```

## Cryptographically secure number generator

Hexadecial string. This method lets you get cryptographically strong random values.

```swift
crypto.generateRandomNumber(length: 16, callback: {(number: String?, error: Error?) in
    print(number!) // aca73dd1c406bf498f1c07a3d607da9f
})
```

## Hash functions

```swift
let input = Data("This is a string".utf8)

crypto.sha1(data: input, callback: {(hash: String?, error: Error?) in
    print(hash!) // 8332d2a25bf1a039d8d296a7b7513960b191d95a
})

crypto.sha256(data: input, callback: {(hash: String?, error: Error?) in
    print(hash!) // a2a0d2d2f3046785436e99dcdc0a2a31b41555eed11750e0067b177b99b6c435
})

crypto.sha384(data: input, callback: {(hash: String?, error: Error?) in
    print(hash!) // e17d41b167194e4836c63bf3cdcf15b2478cb6fda5887485d5f568c98ed45e3a9bab16e7fe68aa8fe14f683f1144fb3a
})

crypto.sha512(data: input, callback: {(hash: String?, error: Error?) in
    print(hash!) // bc5d1ce2a9287ab94f1ed7eff379fbdab5e10d79f8f9dc4f921a2511f418e84561c8d6f63120cd960ea1f48afe09b3bffe2232bb920cc78a2bc873e05e76b30c
})
```

## Built With

* [WebCryptoAPI](https://www.w3.org/TR/WebCryptoAPI/) - JavaScript API for performing basic cryptographic operations 
* [Forge](https://github.com/digitalbazaar/forge) - Used for the openssl key derivation function
* [SparkMD5](https://github.com/satazor/js-spark-md5) - Used for the openssl key derivation function


## Contributing

When contributing to this repository, please first discuss the change you wish to make via issue, email, or any other method with the owners of this repository before making a change.

Update the README.md with details of changes to the plugin.

Update the [examples](https://github.com/etienne-martin/CryptoJS.swift/blob/master/Crypto%20JS/ViewController.swift) by demonstrating the changes to the plugin.

Build the project & test all the features before submitting your pull request.

## Authors

* **Etienne Martin** - *Initial work* - [etiennemartin.ca](http://etiennemartin.ca/)

## License

This project is licensed under the MIT License - see the [LICENSE](https://github.com/etienne-martin/WebCrypto.swift/blob/master/LICENSE) file for details
