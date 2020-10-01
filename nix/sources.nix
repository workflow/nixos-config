# This file has been generated by Niv.

# A record, from name to path, of the third-party packages
with rec
{
  pkgs =
    if hasNixpkgsPath
    then
      if hasThisAsNixpkgsPath
      then import (builtins_fetchTarball { inherit (sources_nixpkgs) url sha256; }) { }
      else import <nixpkgs> { }
    else
      import (builtins_fetchTarball { inherit (sources_nixpkgs) url sha256; }) { };

  sources_nixpkgs =
    if builtins.hasAttr "nixpkgs" sources
    then sources.nixpkgs
    else
      abort
        ''
          Please specify either <nixpkgs> (through -I or NIX_PATH=nixpkgs=...) or
          add a package called "nixpkgs" to your sources.json.
        '';

  # fetchTarball version that is compatible between all the versions of Nix
  builtins_fetchTarball =
    { url, sha256 }@attrs:
    let
      inherit (builtins) lessThan nixVersion fetchTarball;
    in
    if lessThan nixVersion "1.12" then
      fetchTarball { inherit url; }
    else
      fetchTarball attrs;

  # fetchurl version that is compatible between all the versions of Nix
  builtins_fetchurl =
    { url, sha256 }@attrs:
    let
      inherit (builtins) lessThan nixVersion fetchurl;
    in
    if lessThan nixVersion "1.12" then
      fetchurl { inherit url; }
    else
      fetchurl attrs;

  # A wrapper around pkgs.fetchzip that has inspectable arguments,
  # annoyingly this means we have to specify them
  fetchzip = { url, sha256 }@attrs: pkgs.fetchzip attrs;

  # A wrapper around pkgs.fetchurl that has inspectable arguments,
  # annoyingly this means we have to specify them
  fetchurl = { url, sha256 }@attrs: pkgs.fetchurl attrs;

  hasNixpkgsPath = (builtins.tryEval <nixpkgs>).success;
  hasThisAsNixpkgsPath =
    (builtins.tryEval <nixpkgs>).success && <nixpkgs> == ./.;

  sources = builtins.fromJSON (builtins.readFile ./sources.json);

  mapAttrs = builtins.mapAttrs or
    (
      f: set: with builtins;
      listToAttrs (map (attr: { name = attr; value = f attr set.${attr}; }) (attrNames set))
    );

  # borrowed from nixpkgs
  functionArgs = f: f.__functionArgs or (builtins.functionArgs f);
  callFunctionWith = autoArgs: f: args:
    let
      auto = builtins.intersectAttrs (functionArgs f) autoArgs;
    in
    f (auto // args);

  getFetcher = spec:
    let
      fetcherName =
        if builtins.hasAttr "type" spec
        then builtins.getAttr "type" spec
        else "builtin-tarball";
    in
    builtins.getAttr fetcherName {
      "tarball" = fetchzip;
      "builtin-tarball" = builtins_fetchTarball;
      "file" = fetchurl;
      "builtin-url" = builtins_fetchurl;
    };
};
# NOTE: spec must _not_ have an "outPath" attribute
mapAttrs
  (
    _: spec:
      if builtins.hasAttr "outPath" spec
      then
        abort
          "The values in sources.json should not have an 'outPath' attribute"
      else
        if builtins.hasAttr "url" spec && builtins.hasAttr "sha256" spec
        then
          spec // { outPath = callFunctionWith spec (getFetcher spec) { }; }
        else spec
  )
  sources
