package aesgcm

import (
	"bytes"

	asm "github.com/mmcloughlin/cryptofuzz/target/chacha20poly1305/fork/asm"
	noasm "github.com/mmcloughlin/cryptofuzz/target/chacha20poly1305/fork/noasm"
)

func Fuzz(data []byte) int {
	// Read key.
	if len(data) < asm.KeySize {
		return -1
	}
	key := data[:asm.KeySize]
	data = data[asm.KeySize:]

	// Read nonce.
	if len(data) < asm.NonceSize {
		return -1
	}
	nonce := data[:asm.NonceSize]
	data = data[asm.NonceSize:]

	// Read plaintext.
	if len(data) == 0 {
		return -1
	}
	plaintext := data

	// Construct implementations to be compared.
	a, err := asm.New(key)
	if err != nil {
		panic(err.Error())
	}

	b, err := noasm.New(key)
	if err != nil {
		panic(err.Error())
	}

	// Seal.
	aciphertext := a.Seal(nil, nonce, plaintext, nil)
	bciphertext := b.Seal(nil, nonce, plaintext, nil)

	if !bytes.Equal(aciphertext, bciphertext) {
		panic("mismatch")
	}

	// Roundtrip.
	roundtrip, err := a.Open(nil, nonce, aciphertext, nil)
	if err != nil {
		panic(err.Error())
	}
	if !bytes.Equal(roundtrip, plaintext) {
		panic("roundtrip failed")
	}

	return 1
}
