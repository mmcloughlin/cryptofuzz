package blake2b

import "golang.org/x/sys/cpu"

// UseAVX2 forces the AVX2 implementation to be used, if available.
func UseAVX2()    { useSSE4, useAVX, useAVX2 = false, false, cpu.X86.HasAVX2 }

// UseAVX forces the AVX implementation to be used, if available.
func UseAVX()     { useSSE4, useAVX, useAVX2 = false, cpu.X86.HasAVX, false }

// UseSSE4 forces the SSE4 implementation to be used, if available.
func UseSSE4()    { useSSE4, useAVX, useAVX2 = cpu.X86.HasSSE41, false, false }

// UseGeneric forces the pure Go implementation to be used.
func UseGeneric() { useSSE4, useAVX, useAVX2 = false, false, false }
