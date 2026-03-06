{
  description = "EmbryOS flake";
  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    treefmt-nix.url = "github:numtide/treefmt-nix";
  };
  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [ inputs.treefmt-nix.flakeModule ];
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];
      perSystem =
        {
          config,
          pkgs,
          ...
        }:
        let
          # This is the cross-compilation package set
          pkgsRiscv = pkgs.pkgsCross.riscv64-embedded;

          mkAlias =
            name: target:
            pkgs.writeShellScriptBin name ''
              exec ${target} "$@"
            '';

          riscvAliases = [
            (mkAlias "riscv-none-elf-gcc" "riscv64-none-elf-gcc")
            (mkAlias "riscv-none-elf-g++" "riscv64-none-elf-g++")
            (mkAlias "riscv-none-elf-as" "riscv64-none-elf-as")
            (mkAlias "riscv-none-elf-ld" "riscv64-none-elf-ld")
            (mkAlias "riscv-none-elf-objdump" "riscv64-none-elf-objdump")
            (mkAlias "riscv-none-elf-objcopy" "riscv64-none-elf-objcopy")
            (mkAlias "riscv-none-elf-ar" "riscv64-none-elf-ar")
            (mkAlias "riscv-none-elf-ranlib" "riscv64-none-elf-ranlib")
            (mkAlias "riscv-none-elf-strip" "riscv64-none-elf-strip")
            (mkAlias "riscv-none-elf-size" "riscv64-none-elf-size")
          ];
        in
        {
          treefmt = {
            projectRootFile = "flake.nix";

            programs = {
              alejandra.enable = true;
              clang-format.enable = true;
              prettier.enable = true;
              shfmt.enable = true;
            };

            settings.formatter = {
              clang-format.includes = [
                "**/*.c"
                "**/*.h"
              ];
              clang-format.excludes = [
                "libfdt/**"
                "chapter12/files/**"
              ];

              prettier.includes = [
                "**/*.md"
                "**/*.yml"
                "**/*.yaml"
                "**/*.json"
                "**/*.clangd"
              ];

              shfmt.includes = [ "**/*.sh" ];
            };
          };

          formatter = config.treefmt.build.wrapper;

          devShells.default = pkgs.mkShell {
            nativeBuildInputs = [
              # Cross-compiler toolchain (runs on your Mac, targets RISC-V)
              pkgsRiscv.buildPackages.gcc
              pkgsRiscv.buildPackages.binutils

              # Dev tools (run on your Mac)
              pkgs.bear
              pkgs.clang-tools
              pkgs.qemu
            ]
            ++ riscvAliases;
          };
        };
    };
}
