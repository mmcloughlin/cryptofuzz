package blake2s

import "golang.org/x/sys/cpu"

// UseSSE4 forces the SSE4 implementation to be used, if available.
func UseSSE4()    { useSSE2, useSSSE3, useSSE4 = false, false, cpu.X86.HasSSE41 }

// UseSSSE3 forces the SSSE3 implementation to be used, if available.
func UseSSSE3()    { useSSE2, useSSSE3, useSSE4 = false, cpu.X86.HasSSSE3, false }

// UseSSE2 forces the SSE2 implementation to be used, if available.
func UseSSE2()    { useSSE2, useSSSE3, useSSE4 = cpu.X86.HasSSE2, false, false }

// UseGeneric forces the pure Go implementation to be used.
func UseGeneric() { useSSE2, useSSSE3, useSSE4 = false, false, false }
