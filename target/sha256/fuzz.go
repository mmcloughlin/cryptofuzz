package sha256

import (
	"github.com/mmcloughlin/cryptofuzz/fuzz"
	asm "github.com/mmcloughlin/cryptofuzz/target/sha256/fork/asm"
	noasm "github.com/mmcloughlin/cryptofuzz/target/sha256/fork/noasm"
)

func Fuzz(data []byte) int {
	return fuzz.Hash(data, asm.New(), noasm.New())
}
