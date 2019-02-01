package sha1

import (
	"github.com/mmcloughlin/cryptofuzz/fuzz"
	asm "github.com/mmcloughlin/cryptofuzz/target/sha1/fork/asm"
	noasm "github.com/mmcloughlin/cryptofuzz/target/sha1/fork/noasm"
)

func Fuzz(data []byte) int {
	return fuzz.Hash(data, asm.New(), noasm.New())
}
