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
      default = libpinedio-usb;
    };

    # Run test suite when checking the flake
    checks = 
      rec {
        inherit (self.packages.${system}) libpinedio-usb;

        test = pkgs.stdenv.mkDerivation 
          {
            pname = "libpinedio-test";
            inherit version;

            buildInputs = [ libpinedio-usb ];
            dontUnpack = true;

            buildPhase = '''';
          };
      };
  });
}
