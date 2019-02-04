#include <stdio.h>
#include <stdlib.h>
#include <assert.h>

#include <openssl/curve25519.h>

// // Curve25519.
// //
// // Curve25519 is an elliptic curve. See https://tools.ietf.org/html/rfc7748.
//
//
// // X25519.
// //
// // X25519 is the Diffie-Hellman primitive built from curve25519. It is
// // sometimes referred to as “curve25519”, but “X25519” is a more precise name.
// // See http://cr.yp.to/ecdh.html and https://tools.ietf.org/html/rfc7748.
//
// #define X25519_PRIVATE_KEY_LEN 32
// #define X25519_PUBLIC_VALUE_LEN 32
// #define X25519_SHARED_KEY_LEN 32
//
// // X25519_keypair sets |out_public_value| and |out_private_key| to a freshly
// // generated, public–private key pair.
// OPENSSL_EXPORT void X25519_keypair(uint8_t out_public_value[32],
//                                    uint8_t out_private_key[32]);
//
// // X25519 writes a shared key to |out_shared_key| that is calculated from the
// // given private key and the peer's public value. It returns one on success and
// // zero on error.
// //
// // Don't use the shared key directly, rather use a KDF and also include the two
// // public values as inputs.
// OPENSSL_EXPORT int X25519(uint8_t out_shared_key[32],
//                           const uint8_t private_key[32],
//                           const uint8_t peer_public_value[32]);
//
// // X25519_public_from_private calculates a Diffie-Hellman public value from the
// // given private key and writes it to |out_public_value|.
// OPENSSL_EXPORT void X25519_public_from_private(uint8_t out_public_value[32],
//                                                const uint8_t private_key[32]);

#define NUM_TEST_VECTORS (1 << 10)

void rand32bytes(uint8_t out[32])
{
    for (int i = 0; i < 32; i++)
    {
        out[i] = rand() & 0xff;
    }
}

void print32bytes(uint8_t x[32])
{
    for (int i = 0; i < 32; i++)
    {
        printf("%02x", x[i]);
    }
}

typedef struct
{
    uint8_t expect[32];
    uint8_t in[32];
    uint8_t base[32];
} testvector_t;

testvector_t testvector_rand()
{
    testvector_t tv;
    rand32bytes(tv.in);
    rand32bytes(tv.base);
    int status = X25519(tv.expect, tv.in, tv.base);
    assert(status == 1);
    return tv;
}

void testvector_print_json(testvector_t tv, char *prefix)
{
    printf("%s{\n", prefix);

    printf("%s\t\"in\": \"", prefix);
    print32bytes(tv.in);
    printf("\",\n");

    printf("%s\t\"base\": \"", prefix);
    print32bytes(tv.base);
    printf("\",\n");

    printf("%s\t\"expect\": \"", prefix);
    print32bytes(tv.expect);
    printf("\"\n");

    printf("%s}", prefix);
}

void testvectors_print_json(testvector_t *tvs, size_t n)
{
    printf("[\n");
    for (size_t i = 0; i < n; i++)
    {
        testvector_print_json(tvs[i], "\t");
        printf(i != n - 1 ? ",\n" : "\n");
    }
    printf("]\n");
}

int main(int argc, char **argv)
{
    srand(42);

    testvector_t tvs[NUM_TEST_VECTORS];
    for (int i = 0; i < NUM_TEST_VECTORS; i++)
    {
        tvs[i] = testvector_rand();
    }

    testvectors_print_json(tvs, NUM_TEST_VECTORS);
}
