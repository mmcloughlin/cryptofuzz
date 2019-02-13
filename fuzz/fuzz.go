// Package fuzz provides generic fuzzers for crypto interfaces.
package fuzz

import (
	"bytes"
	"crypto/elliptic"
	"encoding/binary"
	"errors"
	"hash"
	"io"
	"math/rand"
)

// ErrShort is returned when fuzz data is too short.
var ErrShort = errors.New("fuzz: provided data too short")

// Rand builds a random source from fuzz data.
func Rand(data []byte) (*rand.Rand, []byte, error) {
	if len(data) < 4 {
		return nil, nil, ErrShort
	}
	seed := binary.BigEndian.Uint32(data)
	data = data[4:]
	r := rand.New(rand.NewSource(int64(seed)))
	return r, data, nil
}

// MustWrite writes b to w and panics if anything goes wrong.
func MustWrite(w io.Writer, b []byte) {
	n, err := w.Write(b)
	if err != nil {
		panic(err.Error())
	}
	if n != len(b) {
		panic("short write")
	}
}

// RandWrite writes b to w in random-sized chunks, based on the given random source.
func RandWrite(w io.Writer, r *rand.Rand, b []byte) {
	for len(b) > 0 {
		m := 1 + r.Intn(len(b))
		chunk := b[:m]
		b = b[m:]
		MustWrite(w, chunk)
	}
}

// Hash compares two hash implementations on the given fuzz data.
func Hash(data []byte, a, b hash.Hash) int {
	r, data, err := Rand(data)
	if err != nil {
		return -1
	}

	// Write to hash in random chunks.
	h := io.MultiWriter(a, b)
	RandWrite(h, r, data)

	// Compare checksums.
	asum := a.Sum(nil)
	bsum := b.Sum(nil)

	if !bytes.Equal(asum, bsum) {
		panic("mismatch")
	}

	return 0
}

// Curve compares c to its generic implementation on the given fuzz data.
func Curve(data []byte, c elliptic.Curve) int {
	ref := c.Params()
	n := ref.BitSize / 8

	// ScalarBaseMult
	if len(data) < n {
		return -1
	}
	s := data[:n]
	data = data[n:]

	x, y := c.ScalarBaseMult(s)
	rx, ry := ref.ScalarBaseMult(s)

	if x.Cmp(rx) != 0 || y.Cmp(ry) != 0 {
		panic("mismatch ScalarBaseMult")
	}

	// ScalarMult
	if len(data) < n {
		return -1
	}
	s = data[:n]
	data = data[n:]

	x, y = c.ScalarMult(x, y, s)
	rx, ry = ref.ScalarMult(rx, ry, s)

	if x.Cmp(rx) != 0 || y.Cmp(ry) != 0 {
		panic("mismatch ScalarMult")
	}

	// Confirm Add and Double have expected properties.
	ax, ay := c.Add(x, y, x, y)
	dx, dy := c.Double(x, y)
	if ax.Cmp(dx) != 0 || ay.Cmp(dy) != 0 {
		panic("mismatch between Add and Double")
	}

	return 0
}
