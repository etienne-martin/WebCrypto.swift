# WebCrypto.swift

A small collection of cryptographic functions based on the JavaScript WebCrypto API. Allows you to share the same crypto between a native iOS/OSX application and a web application.

### The story

The original [CryptoJS.swift](https://github.com/etienne-martin/CryptoJS.swift) library was developed in 2015 as I needed a way to share the same cryptography between a Swift application and a web app. My goal was achieved by using the same JavaScript [CryptoJS library](https://github.com/brix/crypto-js) in both environments. CryptoJS is no longer maintained and  suffers severe performance limitations over the new [WebCrypto API](https://developer.mozilla.org/en-US/docs/Web/API/Web_Crypto_API). 

This project leverages the power of the WebCrypto API while keeping backwards compatibility with CryptoJS.swift. All methods are asynchronous and run on a separate thread. 

## Performance

In comparison with other available solutions, here are the results obtained when encrypting a 10MB file with AES-256 on a 2.6 GHz Intel Core i7.
  
**RNCryptor**        92ms  
**openSSL:**         139ms   
**WebCrypto.swift:** 1545ms   
**CryptoSwift:**     24366ms  

## Usage 

1. Drag and drop [WebCrypto.swift](https://raw.githubusercontent.com/etienne-martin/WebCrypto.swift/master/WebCrypto/WebCrypto.swift) and [WebCrypto.js](https://raw.githubusercontent.com/etienne-martin/WebCrypto.swift/master/WebCrypto/WebCrypto.js) into your Xcode project.  
2. Initialize the WebCrypto class in your code:

```swift
let crypto = WebCrypto()
```

3. That's it. No bridging header required.

#### Data types conversion

WebCrypto.swift works with Swift's ```Data``` object. If you need to pass a string to a method, you first need to convert it to ```Data``` before passing it as an input. 

Convert ```String``` to ```Data```:

```swift
let data = Data("This is a string".utf8)
```

Convert ```Data``` to ```String```:

```swift
let string = String(data: data, encoding: .utf8)
```

Convert ```Data``` to hex encoded string:

```swift
let hex = crypto.hexEncodedStringFromData(data)
```

Convert hex encoded string to ```Data```:

```swift
let data = crypto.dataFromHexEncodedString(hex)
```

## AES

The algorithm used by WebCrypto.swift is the cipher-block chaining ([CBC](https://en.wikipedia.org/wiki/Block_cipher_mode_of_operation#Cipher_Block_Chaining_.28CBC.29)) mode. For key generation, it uses [PKCS7](https://en.wikipedia.org/wiki/PKCS) as the padding method.

WebCrypto.swift supports AES-128, AES-192, and AES-256. It will pick the variant by the size of the key you pass in. If you use a password, AES-256 will be used.

### Password-based encryption

WebCrypto.swift uses a salted key derivation algorithm. The salt is a piece of random bytes which are generated when encrypting, and stored in the file header; upon decryption, the salt is retrieved from the header, and the key and IV are recomputed from the provided password and the salt value.

The key derivation algorithm is the same as the one used by [openSSL](https://en.wikipedia.org/wiki/OpenSSL), making it compatible with openSSL and other libraries like CryptoJS.

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

This method requires a key and an IV in hexadecimal format. Use the [generateKey](https://github.com/etienne-martin/WebCrypto.swift#encryption-keys) and [generateIv](https://github.com/etienne-martin/WebCrypto.swift#initialization-vectors) methods if you need to generate a new key and IV. **Remember to never re-use an initialization vector. Always generate a new IV every time you encrypt.**

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

This method generates 128, 192, or 256-bit hex-encoded keys. If the length parameter is omitted, the output is a 256-bit key by default.

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

This method generates a 16-bit hex-encoded IV. **Remember to never re-use an initialization vector. Always generate a new IV every time you encrypt.**

```swift
crypto.generateIv(callback: {(iv: String?, error: Error?) in
    print(iv!) // a408350a6ef6ceb8883173778d700b0a
})
```

## Cryptographically secure number generator

This method lets you get cryptographically strong random values. The output is a hex-encoded string. **Do not generate keys using this method.** Use the [generateKey](https://github.com/etienne-martin/WebCrypto.swift#encryption-keys) method instead.

```swift
crypto.generateRandomNumber(length: 16, callback: {(number: String?, error: Error?) in
    print(number!) // aca73dd1c406bf498f1c07a3d607da9f
})
```

## Hash functions

These methods compute the hash of a data object and output its hexadecimal digest.

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

## Error handling

Check whether the ```error``` value is non-nil to know if an error has occurred.

```swift 
let input = Data("This is a string".utf8)

let password = "password123"

crypto.encrypt(data: input, password: password, callback: {(encrypted: Data?, error: Error?) in
    if let errorMessage = error {
        // Something went wrong
        print(errorMessage)
    }else{
        // Success
        print(encrypted!)
    }
})
```

## Built with

* [WebCryptoAPI](https://www.w3.org/TR/WebCryptoAPI/) - JavaScript API for performing basic cryptographic operations 
* [Forge](https://github.com/digitalbazaar/forge) - Used for the openSSL key derivation function
* [SparkMD5](https://github.com/satazor/js-spark-md5) - Used for the openSSL key derivation function


## Contributing

When contributing to this repository, please first discuss the change you wish to make via issue, email, or any other method with the owners of this repository before making a change.

Update the [README.md](https://github.com/etienne-martin/WebCrypto.swift) with details of changes to the library.

Update the [examples](https://github.com/etienne-martin/WebCrypto.swift/blob/master/WebCrypto/AppDelegate.swift) by demonstrating the changes to the library.

Build the project and test all the features before submitting your pull request.

## Authors

* **Etienne Martin** - *Initial work* - [etiennemartin.ca](http://etiennemartin.ca/)

## License

This project is licensed under the MIT License - see the [LICENSE](https://github.com/etienne-martin/WebCrypto.swift/blob/master/LICENSE) file for details
