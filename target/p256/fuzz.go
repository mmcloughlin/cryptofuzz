package sha1

import (
	"crypto/elliptic"

	"github.com/mmcloughlin/cryptofuzz/fuzz"
)

func Fuzz(data []byte) int {
	return fuzz.Curve(data, elliptic.P256())
}
