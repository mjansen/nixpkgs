{ fetchurl, stdenv, glib, xlibs, cairo, gtk, pango, makeWrapper, openssl, bzip2 }:

assert stdenv.system == "i686-linux" || stdenv.system == "x86_64-linux";

let
  build = "3083";
  libPath = stdenv.lib.makeLibraryPath [glib xlibs.libX11 gtk cairo pango];
in let
  # package with just the binaries
  sublime = stdenv.mkDerivation {
    name = "sublimetext3-${build}-bin";

    src =
      if stdenv.system == "i686-linux" then
        fetchurl {
          name = "sublimetext-3.0.83.tar.bz2";
          url = "http://c758482.r82.cf2.rackcdn.com/sublime_text_3_build_${build}_x32.tar.bz2";
          sha256 = "0r9irk2gdwdx0dk7lgssr4krfvf3lf71pzaz5hyjc704zaxf5s49";
        }
      else
        fetchurl {
          name = "sublimetext-3.0.83.tar.bz2";
          url = "http://c758482.r82.cf2.rackcdn.com/sublime_text_3_build_${build}_x64.tar.bz2";
          sha256 = "1vhlrqz7xscmjnxpz60mdpvflanl26d7673ml7psd75n0zvcfra5";
        };

    dontStrip = true;
    dontPatchELF = true;
    buildInputs = [ makeWrapper ];

    buildPhase = ''
      for i in sublime_text plugin_host crash_reporter; do
        patchelf \
          --interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
          --set-rpath ${libPath}:${stdenv.cc.cc}/lib${stdenv.lib.optionalString stdenv.is64bit "64"} \
          $i
      done
    '';

    installPhase = ''
      mkdir -p $out
      cp -prvd * $out/
      # Without this, plugin_host crashes, even though it has the rpath
      wrapProgram $out/plugin_host --prefix LD_PRELOAD : ${stdenv.cc.cc}/lib${stdenv.lib.optionalString stdenv.is64bit "64"}/libgcc_s.so.1:${openssl}/lib/libssl.so:${bzip2}/lib/libbz2.so
    '';
  };
in stdenv.mkDerivation {
  name = "sublimetext3-${build}";

  phases = [ "installPhase" ];
  installPhase = ''
    mkdir -p $out/bin
    ln -s ${sublime}/sublime_text $out/bin/sublime
    ln -s ${sublime}/sublime_text $out/bin/sublime3
  '';

  meta = {
    description = "Sophisticated text editor for code, markup and prose";
    maintainers = [ stdenv.lib.maintainers.wmertens ];
    license = stdenv.lib.licenses.unfree;
  };
}
