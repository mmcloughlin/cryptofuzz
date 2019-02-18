# cryptofuzz

Fuzzing Go crypto with [`go-fuzz`](https://github.com/dvyukov/go-fuzz).

## Targets

Fuzzers compare assembly implementations to the corresponding pure Go versions.

* [aesgcm](target/aesgcm): `crypto/aes` GCM mode
* [chacha20poly1305](target/chacha20poly1305): `x/crypto/chacha20poly1305`
* [curve25519](target/curve25519): `x/crypto/curve25519`
* [p256](target/p256): `crypto/elliptic` P-256 curve
* [sha1](target/sha1): `crypto/sha1`
* [sha256](target/sha256): `crypto/sha256`
* [sha512](target/sha512): `crypto/sha512`
* [sha3](target/sha3): `x/crypto/sha3`
* [blake2b](target/blake2b): `x/crypto/blake2b`
* [blake2s](target/blake2s): `x/crypto/blake2s`
* [argon2](target/argon2): `x/crypto/argon2`

## Quick Start

Install dependencies with

```sh
$ ./script/bootstrap
```

Then start a fuzzer with `./script/fuzz <target>` where `<target>` is one of the subdirectories of [`target/`](target), for example

```
$ ./script/fuzz sha1
...
2019/02/05 22:37:37 workers: 4, corpus: 56 (3s ago), crashers: 0, restarts: 1/0, execs: 0 (0/sec), cover: 0, uptime: 3s
2019/02/05 22:37:40 workers: 4, corpus: 56 (6s ago), crashers: 0, restarts: 1/4459, execs: 40139 (6666/sec), cover: 124, uptime: 6s
2019/02/05 22:37:43 workers: 4, corpus: 56 (9s ago), crashers: 0, restarts: 1/4349, execs: 52191 (5787/sec), cover: 124, uptime: 9s
2019/02/05 22:37:46 workers: 4, corpus: 56 (12s ago), crashers: 0, restarts: 1/6450, execs: 103200 (8588/sec), cover: 124, uptime: 12s
...
```

## Infrastructure

The [`infra/`](infra) directory contains [Terraform](https://www.terraform.io/) configuration to run fuzzers on [EC2 spot fleets](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/spot-fleet.html) (to minimize cost). Before you proceed note that this _will cost you money_.

To utilize this infrastructure, first build an archive to distribute to the boxes

```
$ GOOS=linux GOARCH=amd64 ./script/dist
```

This should build an archive of all files required to run the fuzzers on EC2 boxes. To setup the infrastructure:

```sh
$ cd infra/
$ terraform init
$ terraform apply -var 'package_path=<path to dist archive>' -var 'targets=["p256", "sha3"]'
```

Note this expects to find AWS credentials in `~/.aws/credentials`. For each specified target, this will setup a coordinator node and a worker fleet. See [`variables.tf`](infra/variables.tf) to configure the size of the worker fleet.
