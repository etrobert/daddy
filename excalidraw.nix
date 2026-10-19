{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchYarnDeps,
  yarnConfigHook,
  nodejs_22,
  yarn,
}:
let
  # excalidraw-app's engines.node allows only 18–22, and yarn enforces it for scripts.
  yarn22 = yarn.override { nodejs = nodejs_22; };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "excalidraw";
  version = "0.18.1";

  src = fetchFromGitHub {
    owner = "excalidraw";
    repo = "excalidraw";
    tag = "v${finalAttrs.version}";
    hash = "sha256-XhxNXi6JwBq5vw+/6HQTp6NPX3etmCkdBdNboeBru/k=";
  };

  yarnOfflineCache = fetchYarnDeps {
    yarnLock = "${finalAttrs.src}/yarn.lock";
    hash = "sha256-otUEr4bGhOGYQmfELShqc8lXbRs0gA0ycbGHzyCW8tc=";
  };

  nativeBuildInputs = [
    yarnConfigHook
    nodejs_22
  ];

  # By absolute path: yarnConfigHook puts a default-node yarn first on PATH.
  buildPhase = ''
    runHook preBuild
    ${lib.getExe yarn22} --cwd excalidraw-app build:app:docker
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    cp -r excalidraw-app/build $out
    runHook postInstall
  '';
})
