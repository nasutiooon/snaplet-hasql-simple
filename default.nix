{ mkDerivation, base, configurator, hasql, hasql-pool, hpack, mtl
, snap, stdenv, text
}:
mkDerivation {
  pname = "snaplet-hasql-simple";
  version = "0.1.0.0";
  src = ./.;
  libraryHaskellDepends = [
    base configurator hasql hasql-pool mtl snap text
  ];
  libraryToolDepends = [ hpack ];
  prePatch = "hpack";
  homepage = "https://github.com/nasutiooon/kos#readme";
  license = stdenv.lib.licenses.bsd3;
}
