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

"use strict";

function initWebCrypto(){
	
// Stripped-down version of SparkMD5, keeping only the hashBinary function
// https://github.com/satazor/js-spark-md5

var add32 = function (a, b) {
        return (a + b) & 0xFFFFFFFF;
    };
var hex_chr = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f'];

function md5cycle(x, k) {
    var a = x[0],
        b = x[1],
        c = x[2],
        d = x[3];

    a += (b & c | ~b & d) + k[0] - 680876936 | 0;
    a  = (a << 7 | a >>> 25) + b | 0;
    d += (a & b | ~a & c) + k[1] - 389564586 | 0;
    d  = (d << 12 | d >>> 20) + a | 0;
    c += (d & a | ~d & b) + k[2] + 606105819 | 0;
    c  = (c << 17 | c >>> 15) + d | 0;
    b += (c & d | ~c & a) + k[3] - 1044525330 | 0;
    b  = (b << 22 | b >>> 10) + c | 0;
    a += (b & c | ~b & d) + k[4] - 176418897 | 0;
    a  = (a << 7 | a >>> 25) + b | 0;
    d += (a & b | ~a & c) + k[5] + 1200080426 | 0;
    d  = (d << 12 | d >>> 20) + a | 0;
    c += (d & a | ~d & b) + k[6] - 1473231341 | 0;
    c  = (c << 17 | c >>> 15) + d | 0;
    b += (c & d | ~c & a) + k[7] - 45705983 | 0;
    b  = (b << 22 | b >>> 10) + c | 0;
    a += (b & c | ~b & d) + k[8] + 1770035416 | 0;
    a  = (a << 7 | a >>> 25) + b | 0;
    d += (a & b | ~a & c) + k[9] - 1958414417 | 0;
    d  = (d << 12 | d >>> 20) + a | 0;
    c += (d & a | ~d & b) + k[10] - 42063 | 0;
    c  = (c << 17 | c >>> 15) + d | 0;
    b += (c & d | ~c & a) + k[11] - 1990404162 | 0;
    b  = (b << 22 | b >>> 10) + c | 0;
    a += (b & c | ~b & d) + k[12] + 1804603682 | 0;
    a  = (a << 7 | a >>> 25) + b | 0;
    d += (a & b | ~a & c) + k[13] - 40341101 | 0;
    d  = (d << 12 | d >>> 20) + a | 0;
    c += (d & a | ~d & b) + k[14] - 1502002290 | 0;
    c  = (c << 17 | c >>> 15) + d | 0;
    b += (c & d | ~c & a) + k[15] + 1236535329 | 0;
    b  = (b << 22 | b >>> 10) + c | 0;

    a += (b & d | c & ~d) + k[1] - 165796510 | 0;
    a  = (a << 5 | a >>> 27) + b | 0;
    d += (a & c | b & ~c) + k[6] - 1069501632 | 0;
    d  = (d << 9 | d >>> 23) + a | 0;
    c += (d & b | a & ~b) + k[11] + 643717713 | 0;
    c  = (c << 14 | c >>> 18) + d | 0;
    b += (c & a | d & ~a) + k[0] - 373897302 | 0;
    b  = (b << 20 | b >>> 12) + c | 0;
    a += (b & d | c & ~d) + k[5] - 701558691 | 0;
    a  = (a << 5 | a >>> 27) + b | 0;
    d += (a & c | b & ~c) + k[10] + 38016083 | 0;
    d  = (d << 9 | d >>> 23) + a | 0;
    c += (d & b | a & ~b) + k[15] - 660478335 | 0;
    c  = (c << 14 | c >>> 18) + d | 0;
    b += (c & a | d & ~a) + k[4] - 405537848 | 0;
    b  = (b << 20 | b >>> 12) + c | 0;
    a += (b & d | c & ~d) + k[9] + 568446438 | 0;
    a  = (a << 5 | a >>> 27) + b | 0;
    d += (a & c | b & ~c) + k[14] - 1019803690 | 0;
    d  = (d << 9 | d >>> 23) + a | 0;
    c += (d & b | a & ~b) + k[3] - 187363961 | 0;
    c  = (c << 14 | c >>> 18) + d | 0;
    b += (c & a | d & ~a) + k[8] + 1163531501 | 0;
    b  = (b << 20 | b >>> 12) + c | 0;
    a += (b & d | c & ~d) + k[13] - 1444681467 | 0;
    a  = (a << 5 | a >>> 27) + b | 0;
    d += (a & c | b & ~c) + k[2] - 51403784 | 0;
    d  = (d << 9 | d >>> 23) + a | 0;
    c += (d & b | a & ~b) + k[7] + 1735328473 | 0;
    c  = (c << 14 | c >>> 18) + d | 0;
    b += (c & a | d & ~a) + k[12] - 1926607734 | 0;
    b  = (b << 20 | b >>> 12) + c | 0;

    a += (b ^ c ^ d) + k[5] - 378558 | 0;
    a  = (a << 4 | a >>> 28) + b | 0;
    d += (a ^ b ^ c) + k[8] - 2022574463 | 0;
    d  = (d << 11 | d >>> 21) + a | 0;
    c += (d ^ a ^ b) + k[11] + 1839030562 | 0;
    c  = (c << 16 | c >>> 16) + d | 0;
    b += (c ^ d ^ a) + k[14] - 35309556 | 0;
    b  = (b << 23 | b >>> 9) + c | 0;
    a += (b ^ c ^ d) + k[1] - 1530992060 | 0;
    a  = (a << 4 | a >>> 28) + b | 0;
    d += (a ^ b ^ c) + k[4] + 1272893353 | 0;
    d  = (d << 11 | d >>> 21) + a | 0;
    c += (d ^ a ^ b) + k[7] - 155497632 | 0;
    c  = (c << 16 | c >>> 16) + d | 0;
    b += (c ^ d ^ a) + k[10] - 1094730640 | 0;
    b  = (b << 23 | b >>> 9) + c | 0;
    a += (b ^ c ^ d) + k[13] + 681279174 | 0;
    a  = (a << 4 | a >>> 28) + b | 0;
    d += (a ^ b ^ c) + k[0] - 358537222 | 0;
    d  = (d << 11 | d >>> 21) + a | 0;
    c += (d ^ a ^ b) + k[3] - 722521979 | 0;
    c  = (c << 16 | c >>> 16) + d | 0;
    b += (c ^ d ^ a) + k[6] + 76029189 | 0;
    b  = (b << 23 | b >>> 9) + c | 0;
    a += (b ^ c ^ d) + k[9] - 640364487 | 0;
    a  = (a << 4 | a >>> 28) + b | 0;
    d += (a ^ b ^ c) + k[12] - 421815835 | 0;
    d  = (d << 11 | d >>> 21) + a | 0;
    c += (d ^ a ^ b) + k[15] + 530742520 | 0;
    c  = (c << 16 | c >>> 16) + d | 0;
    b += (c ^ d ^ a) + k[2] - 995338651 | 0;
    b  = (b << 23 | b >>> 9) + c | 0;

    a += (c ^ (b | ~d)) + k[0] - 198630844 | 0;
    a  = (a << 6 | a >>> 26) + b | 0;
    d += (b ^ (a | ~c)) + k[7] + 1126891415 | 0;
    d  = (d << 10 | d >>> 22) + a | 0;
    c += (a ^ (d | ~b)) + k[14] - 1416354905 | 0;
    c  = (c << 15 | c >>> 17) + d | 0;
    b += (d ^ (c | ~a)) + k[5] - 57434055 | 0;
    b  = (b << 21 |b >>> 11) + c | 0;
    a += (c ^ (b | ~d)) + k[12] + 1700485571 | 0;
    a  = (a << 6 | a >>> 26) + b | 0;
    d += (b ^ (a | ~c)) + k[3] - 1894986606 | 0;
    d  = (d << 10 | d >>> 22) + a | 0;
    c += (a ^ (d | ~b)) + k[10] - 1051523 | 0;
    c  = (c << 15 | c >>> 17) + d | 0;
    b += (d ^ (c | ~a)) + k[1] - 2054922799 | 0;
    b  = (b << 21 |b >>> 11) + c | 0;
    a += (c ^ (b | ~d)) + k[8] + 1873313359 | 0;
    a  = (a << 6 | a >>> 26) + b | 0;
    d += (b ^ (a | ~c)) + k[15] - 30611744 | 0;
    d  = (d << 10 | d >>> 22) + a | 0;
    c += (a ^ (d | ~b)) + k[6] - 1560198380 | 0;
    c  = (c << 15 | c >>> 17) + d | 0;
    b += (d ^ (c | ~a)) + k[13] + 1309151649 | 0;
    b  = (b << 21 |b >>> 11) + c | 0;
    a += (c ^ (b | ~d)) + k[4] - 145523070 | 0;
    a  = (a << 6 | a >>> 26) + b | 0;
    d += (b ^ (a | ~c)) + k[11] - 1120210379 | 0;
    d  = (d << 10 | d >>> 22) + a | 0;
    c += (a ^ (d | ~b)) + k[2] + 718787259 | 0;
    c  = (c << 15 | c >>> 17) + d | 0;
    b += (d ^ (c | ~a)) + k[9] - 343485551 | 0;
    b  = (b << 21 | b >>> 11) + c | 0;

    x[0] = a + x[0] | 0;
    x[1] = b + x[1] | 0;
    x[2] = c + x[2] | 0;
    x[3] = d + x[3] | 0;
}
function md5blk(s) {
    var md5blks = [],
        i; /* Andy King said do it this way. */

    for (i = 0; i < 64; i += 4) {
        md5blks[i >> 2] = s.charCodeAt(i) + (s.charCodeAt(i + 1) << 8) + (s.charCodeAt(i + 2) << 16) + (s.charCodeAt(i + 3) << 24);
    }
    return md5blks;
}
function md51(s) {
    var n = s.length,
        state = [1732584193, -271733879, -1732584194, 271733878],
        i,
        length,
        tail,
        tmp,
        lo,
        hi;

    for (i = 64; i <= n; i += 64) {
        md5cycle(state, md5blk(s.substring(i - 64, i)));
    }
    s = s.substring(i - 64);
    length = s.length;
    tail = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
    for (i = 0; i < length; i += 1) {
        tail[i >> 2] |= s.charCodeAt(i) << ((i % 4) << 3);
    }
    tail[i >> 2] |= 0x80 << ((i % 4) << 3);
    if (i > 55) {
        md5cycle(state, tail);
        for (i = 0; i < 16; i += 1) {
            tail[i] = 0;
        }
    }

    // Beware that the final length might not fit in 32 bits so we take care of that
    tmp = n * 8;
    tmp = tmp.toString(16).match(/(.*?)(.{0,8})$/);
    lo = parseInt(tmp[2], 16);
    hi = parseInt(tmp[1], 16) || 0;

    tail[14] = lo;
    tail[15] = hi;

    md5cycle(state, tail);
    return state;
}
function rhex(n) {
    var s = '',
        j;
    for (j = 0; j < 4; j += 1) {
        s += hex_chr[(n >> (j * 8 + 4)) & 0x0F] + hex_chr[(n >> (j * 8)) & 0x0F];
    }
    return s;
}
function hex(x) {
    var i;
    for (i = 0; i < x.length; i += 1) {
        x[i] = rhex(x[i]);
    }
    return x.join('');
}
function hexToBinaryString(hex) {
    var bytes = [],
        length = hex.length,
        x;

    for (x = 0; x < length - 1; x += 2) {
        bytes.push(parseInt(hex.substr(x, 2), 16));
    }

    return String.fromCharCode.apply(String, bytes);
}
function hashBinary(content) {
    var hash = md51(content),
        ret = hex(hash);

    return hexToBinaryString(ret);
}

// OpenSSL key derivation functions extracted from forge
// https://github.com/digitalbazaar/forge

function opensslDeriveBytes(password, salt, dkLen){	
	if(salt === null) {
		salt = '';
	}
	var digests = [hashBinary(password + salt)];
	for(var length = 16, i = 1; length < dkLen; ++i, length += 16) {
		digests.push(hashBinary(digests[i - 1] + password + salt));
	}
	return digests.join('').substr(0, dkLen);
}
function ByteStringBuffer(b){
	this.data = '';
	this.read = 0;
	
	if( typeof b === 'string' ){
		this.data = b;
	}else if( util.isArrayBuffer(b) || util.isArrayBufferView(b) ){
		// convert native buffer to forge buffer
		// FIXME: support native buffers internally instead
		var arr = new Uint8Array(b);
		try {
		  this.data = String.fromCharCode.apply(null, arr);
		}catch(e){
			for( var i = 0; i < arr.length; ++i ){
				this.putByte(arr[i]);
			}
		}
	}else if( b instanceof ByteStringBuffer || (typeof b === 'object' && typeof b.data === 'string' && typeof b.read === 'number') ){
		// copy existing buffer
		this.data = b.data;
		this.read = b.read;
	}

	// used for v8 optimization
	this._constructedStringLength = 0;
  
	this.getBytes = function(count){
		var rval;
		if( count ){
			// read count bytes
			count = Math.min(this.length(), count);
			rval = this.data.slice(this.read, this.read + count);
			this.read += count;
		}else if( count === 0 ){
			rval = '';
		}else{
			// read all bytes, optimize to only copy when needed
			rval = (this.read === 0) ? this.data : this.data.slice(this.read);
			this.clear();
		}
		return rval;
	};
	
	this.length = function(){
		return this.data.length - this.read;
	};
}
function createBuffer(input){
	return new ByteStringBuffer(input);
}
function saltShaker(){
	return arrayBufferToString(window.crypto.getRandomValues(new Uint8Array(8)));
}
function derivePassword(password, salt){
	var keySize = 32; // generate 32-byte (256-bit) key
	var ivSize = 16;
	
	var salt = !salt ? saltShaker() : salt;
	var derivedBytes = opensslDeriveBytes(password, salt, keySize + ivSize);
	
	var buffer = createBuffer(derivedBytes);
	var key = buffer.getBytes(keySize);
	var iv = buffer.getBytes(ivSize);
	
	return {key:key, iv: iv, salt: salt};
}

// Helpers

if( window.crypto && !window.crypto.subtle && window.crypto.webkitSubtle ){
    var cryptoSubtle = window.crypto.webkitSubtle;
}else{
    var cryptoSubtle = window.crypto.subtle;
}

function postMessage(message){
	// Handle javascript callback
	if (typeof message.callback === "function") {
		message.callback(message);
	}else{
		try{
			// Handle swift callback
	    	window.webkit.messageHandlers.scriptHandler.postMessage(message);
		}catch(e){}
    }
}
    
function hex2a(hexx){
    var hex = hexx.toString();//force conversion
    var str = '';
    for (var i = 0; i < hex.length; i += 2)
        str += String.fromCharCode(parseInt(hex.substr(i, 2), 16));
    return str;
}
function a2hex(buffer) { // buffer is an ArrayBuffer
  // create a byte array (Uint8Array) that we can use to read the array buffer
  var byteArray = new Uint8Array(buffer);
  
  // for each element, we want to get its two-digit hexadecimal representation
  var hexParts = [];
  for( var i = 0; i < byteArray.length; i++ ){
    // convert value to hexadecimal
    var hex = byteArray[i].toString(16);
    
    // pad with zeros to length 2
    var paddedHex = ('00' + hex).slice(-2);
    
    // push to array
    hexParts.push(paddedHex);
  }
  
  // join all the hex values of the elements into a single string
  return hexParts.join('');
}
function stringToArrayBuffer(str){
    var bytes = new Uint8Array(str.length);
    for (var iii = 0; iii < str.length; iii++){
        bytes[iii] = str.charCodeAt(iii);
    }
    
    return bytes;
}
function arrayBufferToString(buffer){
    var str = "";
    for (var iii = 0; iii < buffer.byteLength; iii++){
        str += String.fromCharCode(buffer[iii]);
    }
    
    return str;
}
function isDefined(variable){
    return typeof variable !== "undefined";
}

// AES functions
    
var saltPrefix = "Salted__";
    
function generateKey(params){
    
    var length = params.length ? params.length : 256; // 256-bit key by default
    var callback = params.callback;
    
    if( length !== 128 && length !== 192 && length !== 256 ){
        postMessage({error: "invalidKeyLength", callback:callback, func: "string"});
        return false;
    }
    
    cryptoSubtle.generateKey({
        name: "AES-CBC",
        length: length, //can be  128, 192, or 256
        },
        true, //whether the key is extractable (i.e. can be used in exportKey)
        ["encrypt", "decrypt"] //can be "encrypt", "decrypt", "wrapKey", or "unwrapKey"
    ).catch(function(error){
        postMessage({error:error, callback:callback, func: "string"});
    }).then(function(key){
        cryptoSubtle.exportKey(
            "raw", //can be "jwk" or "raw"
            key //extractable must be true
        ).catch(function(error){
            postMessage({error:error, callback:callback, func: "string"});
        }).then(function(keydata){
            var key = a2hex(new Uint8Array(keydata));
            postMessage({result: key, callback: callback, func: "string"});
        })
    })
}
    
function generateRandomNumber(params){
    var length = params.length;
    var callback = params.callback;
    
    if( !isDefined(length) || isNaN(parseInt(length)) ){
        postMessage({error: "invalidLength", callback:callback, func: "string"});
        return false;
    }
    
    var randomNumber = a2hex(window.crypto.getRandomValues(new Uint8Array(length)));
    postMessage({result: randomNumber, callback: callback, func: "string"});
}
    
function encrypt(params){
	
	var callback = params.callback;
	
	if( !isDefined(params.data) ){
        postMessage({error: "missingData", callback:callback, func: "data"});
        return false;
	}
    
    var data = atob(params.data);
	var password = params.password;
	var key = params.key;
	var IV = params.iv;
	
	var plaintextData = stringToArrayBuffer(data);
    
    if( isDefined(password) ){
        
        if( password.length === 0 ){
            postMessage({error: "invalidPasswordLength", callback:callback, func: "data"});
            return false;
        }
        
		var derivedPassword = derivePassword(password);
		var key = stringToArrayBuffer(derivedPassword.key);
	    var IV = stringToArrayBuffer(derivedPassword.iv);
		var salt = derivedPassword.salt;
	
	}else if( isDefined(key) && isDefined(IV) ){
        
		key = stringToArrayBuffer(hex2a(key));
	    IV = stringToArrayBuffer(hex2a(IV));
        
        if( params.key.length !== 32 && params.key.length !== 48 && params.key.length !== 64 ){
            postMessage({error: "invalidKeyLength", callback:callback, func: "data"});
            return false;
        }else if( params.iv.length !== 32 ){
            postMessage({error: "invalidIvLength", callback:callback, func: "data"});
            return false;
        }
	}else{
        postMessage({error: "missingPasswordKeyOrIv", callback:callback, func: "data"});
        return false;
	}
    
    cryptoSubtle.importKey("raw", key, {name: "AES-CBC"}, false, ["encrypt", "decrypt"]).catch(function(error){
        postMessage({error:error, callback:callback, func: "data"});
    }).then(function(cryptokey){
                                                                                              
        cryptoSubtle.encrypt({
		    	name: "AES-CBC",
		        //Don't re-use initialization vectors!
		        //Always generate a new iv every time your encrypt!
		        iv: IV,
		    },
		    cryptokey,
		    plaintextData
		
		).catch(function(error){
            postMessage({error:error, callback:callback, func: "data"});
		}).then(function(result){                    
            var encryptedData = arrayBufferToString(new Uint8Array(result));
            
            if( salt ){
	            encryptedData = saltPrefix+salt+encryptedData;
            }
            
            // Base64 encode the data
            encryptedData = btoa(encryptedData);
             
            postMessage({result: encryptedData, callback: callback, func: "data"});
               
		})
                                                                                              
    })
}

function decrypt(params){
	
	var callback = params.callback;
	
	if( !isDefined(params.data) ){
        postMessage({error: "missingData", callback:callback, func: "data"});
        return false;
	}
	
	var data = atob(params.data);
	var password = params.password;
	var key = params.key;
	var IV = params.iv;
	
	var encryptedData = stringToArrayBuffer(data);
    
    // Check if there's a salt
    if( data.substr(0,8) === saltPrefix ){
    	var salt = data.substr(8,8);
    	encryptedData = stringToArrayBuffer(data.substr(16,data.length));
	}
	
    if( isDefined(password) ){
        
        if( password.length === 0 ){
            postMessage({error: "invalidPasswordLength", callback:callback, func: "data"});
            return false;
        }
        
		var derivedPassword = derivePassword(password, salt);
		var key = stringToArrayBuffer(derivedPassword.key);
	    var IV = stringToArrayBuffer(derivedPassword.iv);
	
	}else if( isDefined(key) && isDefined(IV) ){
        
		key = stringToArrayBuffer(hex2a(key));
	    IV = stringToArrayBuffer(hex2a(IV));
        
        if( params.key.length !== 32 && params.key.length !== 48 && params.key.length !== 64 ){
            postMessage({error: "invalidKeyLength", callback:callback, func: "data"});
            return false;
            
        }else if( params.iv.length !== 32 ){
            postMessage({error: "invalidIvLength", callback:callback, func: "data"});
            return false;
        }
	}else{
        postMessage({error: "missingPasswordKeyOrIv", callback:callback, func: "data"});
        return false;
	}
    
    cryptoSubtle.importKey("raw", key, {name: "AES-CBC"}, false, ["encrypt", "decrypt"]).catch(function(error){
        postMessage({error: error, callback: callback, func: "data"});
    }).then(function(cryptokey){
    
        cryptoSubtle.decrypt({ name: "AES-CBC", iv: IV }, cryptokey, encryptedData).catch(function(error){
            postMessage({error: error, callback: callback, func: "data"});
        }).then(function(result){
            var decryptedData = btoa(arrayBufferToString(new Uint8Array(result)));
                              
            postMessage({result: decryptedData, callback: callback, func: "data"});

        })

    })
}
    
// Hashing functions
    
function hash(params){
	
	// TODO: Validate algorithm
    
    var algorithm = params.algorithm; // SHA-1, SHA-256, SHA-384 or SHA-512
    var data = stringToArrayBuffer(atob(params.data));
    var callback = params.callback;
        
    cryptoSubtle.digest({ name: algorithm, }, data).catch(function(error){
        postMessage({error: error, callback: callback, func: "string"});
    }).then(function(hash){
        var hash = a2hex(new Uint8Array(hash));
        postMessage({result: hash, callback: callback, func: "string"});
    })
}
    
// Export

window.WebCrypto = {
    generateKey: generateKey,
    generateRandomNumber: generateRandomNumber,
    encrypt: encrypt,
    decrypt: decrypt,
    hash: hash
};

}