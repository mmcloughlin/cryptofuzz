# cryptofuzz
Fuzzing Go crypto

## Background

Go has some *huge* assembly cryptography implementations in its standard library.

```
$ find $GOROOT/src -path '*crypto*_amd64.s' | xargs wc -l | sort -nr | head
   12921 total
    2695 /usr/local/Cellar/go/1.11/libexec/src/vendor/golang_org/x/crypto/chacha20poly1305/chacha20poly1305_amd64.s
    2348 /usr/local/Cellar/go/1.11/libexec/src/crypto/elliptic/p256_asm_amd64.s
    1500 /usr/local/Cellar/go/1.11/libexec/src/crypto/sha1/sha1block_amd64.s
    1468 /usr/local/Cellar/go/1.11/libexec/src/crypto/sha512/sha512block_amd64.s
    1377 /usr/local/Cellar/go/1.11/libexec/src/vendor/golang_org/x/crypto/curve25519/ladderstep_amd64.s
    1286 /usr/local/Cellar/go/1.11/libexec/src/crypto/aes/gcm_amd64.s
    1031 /usr/local/Cellar/go/1.11/libexec/src/crypto/sha256/sha256block_amd64.s
     274 /usr/local/Cellar/go/1.11/libexec/src/crypto/aes/asm_amd64.s
     179 /usr/local/Cellar/go/1.11/libexec/src/crypto/rc4/rc4_amd64.s
```

Are they correct? Fuzzing is one way to find out.
