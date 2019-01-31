package aesgcm

import (
	"bytes"
	"crypto/aes"
	"crypto/cipher"
)

// Reference: https://github.com/golang/go/blob/f2a416b90ac68596ea05b97cefa8c72e7416e98f/src/crypto/cipher/gcm.go#L84-L86
//
//	func NewGCM(cipher Block) (AEAD, error) {
//		return newGCMWithNonceAndTagSize(cipher, gcmStandardNonceSize, gcmTagSize)
//	}
//
// Reference: https://github.com/golang/go/blob/f2a416b90ac68596ea05b97cefa8c72e7416e98f/src/crypto/cipher/gcm.go#L147-L152
//
//	const (
//		gcmBlockSize         = 16
//		gcmTagSize           = 16
//		gcmMinimumTagSize    = 12 // NIST SP 800-38D recommends tags with 12 or more bytes.
//		gcmStandardNonceSize = 12
//	)
//

const (
	noncesize = 12
)

func Fuzz(data []byte) int {
	// Decide if key should be 128 or 256 bit.
	if len(data) == 0 {
		return -1
	}
	chooser := data[0]
	data = data[1:]
	keybytes := 32 >> (chooser % 1)

	// Read key.
	if len(data) < keybytes {
		return -1
	}
	key := data[:keybytes]
	data = data[keybytes:]

	// Read nonce.
	if len(data) < noncesize {
		return -1
	}
	nonce := data[:noncesize]
	data = data[noncesize:]

	// Read plaintext.
	if len(data) == 0 {
		return -1
	}
	plaintext := data

	// Construct AES block cipher.
	a, err := aes.NewCipher(key)
	if err != nil {
		panic(err.Error())
	}

	b := purego{wrapped: a}

	// Construct GCM.
	agcm, err := cipher.NewGCM(a)
	if err != nil {
		panic(err.Error())
	}

	bgcm, err := cipher.NewGCM(b)
	if err != nil {
		panic(err.Error())
	}

	// Seal.
	aciphertext := agcm.Seal(nil, nonce, plaintext, nil)
	bciphertext := bgcm.Seal(nil, nonce, plaintext, nil)

	if !bytes.Equal(aciphertext, bciphertext) {
		panic("mismatch")
	}

	return 1
}

type purego struct {
	wrapped cipher.Block
}

func (p purego) BlockSize() int          { return p.wrapped.BlockSize() }
func (p purego) Encrypt(dst, src []byte) { p.wrapped.Encrypt(dst, src) }
func (p purego) Decrypt(dst, src []byte) { p.wrapped.Decrypt(dst, src) }
