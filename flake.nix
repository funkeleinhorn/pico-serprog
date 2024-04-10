{
  description = "Pico Serprog Firmware";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    tiny-usb.url = "github:hathach/tinyusb";
    tiny-usb.flake = false;
  };
  outputs = { self, nixpkgs, flake-utils, tiny-usb }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system};
      in
      with pkgs; {
        devShell = mkShell {
          nativeBuildInputs =
            [
              python3
              cmake
              gcc-arm-embedded
              pico-sdk
            ];
          PICO_SDK_PATH = "${pico-sdk}/lib/pico-sdk";
          PICO_TINYUSB_PATH = "${tiny-usb}";
        };
        defaultPackage = stdenv.mkDerivation {
          name = "pico-serprog";
          src = ./.;
          nativeBuildInputs = [
            python3
            pkg-config
            cmake
            gcc-arm-embedded
            pico-sdk
          ];
          cmakeFlags = [
            "-DCMAKE_C_COMPILER=${gcc-arm-embedded}/bin/arm-none-eabi-gcc"
            "-DCMAKE_CXX_COMPILER=${gcc-arm-embedded}/bin/arm-none-eabi-g++"
            "-DPICO_SDK_PATH=${pico-sdk}/lib/pico-sdk"
            "-DPICO_TINYUSB_PATH=${tiny-usb}"
          ];
          installPhase = ''
            mkdir -p $out/bin
            mv ./pico_serprog.* $out/bin
          '';
        };
        formatter = pkgs.nixpkgs-fmt;
      }
    );
}
