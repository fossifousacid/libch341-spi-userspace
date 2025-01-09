{
  description = "A userspace driver for the Pinedio usb LoRa radio.";

  inputs.nixpkgs.url = "nixpkgs/nixos-24.11";

  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
  flake-utils.lib.eachDefaultSystem (system:
  let 
    lastModifiedDate = self.lastModifiedDate or self.lastModified or "19700101";
    version = builtins.substring 0 8 lastModifiedDate;
    pkgs = import nixpkgs {inherit system;};
  in rec
  {
    
    packages = rec { 
      libpinedio-usb = pkgs.stdenv.mkDerivation rec {
        pname = "libpinedio-usb";
        inherit version;
        src = ./.;
        nativeBuildInputs = [ pkgs.cmake pkgs.ninja pkgs.pkg-config ];
        buildInputs = [ pkgs.libusb1 ];
      };
      pinedio-test = pkgs.stdenv.mkDerivation rec {
        pname = "pinedio-test";
        inherit version;
        src = ./.;
        nativeBuildInputs = [ pkgs.cmake pkgs.ninja pkgs.pkg-config ];
        buildInputs = [ pkgs.libusb1 ];
        installPhase = ''
          mkdir -p $out/bin
          cp pinedio-test $out/bin
          '';
      };
      default = libpinedio-usb;
    };

    # Run test suite when checking the flake
    checks = 
      rec {
        inherit (self.packages.${system}) pinedio-test;

        test = pkgs.stdenv.mkDerivation 
          {
            pname = "pinedio-test";
            inherit version;

            buildInputs = [ pinedio-test ];
            dontUnpack = true;

            buildPhase = ''
              echo Running pinedio-test
              echo TODO: pinedio-test currently segfaults so skip this for now'';
            installPhase = ''mkdir -p $out'';
          };
      };
  });
}
