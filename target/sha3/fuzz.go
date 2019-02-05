package sha3

import (
	"github.com/mmcloughlin/cryptofuzz/fuzz"
	asm "github.com/mmcloughlin/cryptofuzz/target/sha3/fork/asm"
	noasm "github.com/mmcloughlin/cryptofuzz/target/sha3/fork/noasm"
)

func Fuzz(data []byte) int {
	return fuzz.Hash(data, asm.New512(), noasm.New512())
}
