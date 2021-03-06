# This file was auto-generated by cabal2nix. Please do NOT edit manually!

{ cabal, transformers }:

cabal.mkDerivation (self: {
  pname = "traverse-with-class";
  version = "0.2.0.3";
  sha256 = "0snms19w3n9ni1wmf4ikwpp298nc6qk6phrjxi5g023ihqqdvr6g";
  buildDepends = [ transformers ];
  meta = {
    description = "Generic applicative traversals";
    license = self.stdenv.lib.licenses.mit;
    platforms = self.ghc.meta.platforms;
    maintainers = with self.stdenv.lib.maintainers; [ ocharles ];
  };
})
