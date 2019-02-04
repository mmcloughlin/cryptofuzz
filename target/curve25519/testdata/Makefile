BORINGSSL_INCLUDE_PATH=$(BORINGSSL_PATH)/include
BORINGSSL_CRYPTO_LIB_PATH=$(BORINGSSL_PATH)/build/crypto

CC=clang

CFLAGS=-Wall -O2
CFLAGS+=-I$(BORINGSSL_INCLUDE_PATH)
LDFLAGS+=-L$(BORINGSSL_CRYPTO_LIB_PATH)
LDLIBS+=-lcrypto

name=testvectors

all: $(name) $(name).json

%.json: %
	./$< > $@

clean:
	$(RM) $(name)