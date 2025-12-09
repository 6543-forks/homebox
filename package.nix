{
  buildGoModule,
  pnpm_9,
  nodejs,
  go_1_24,
  git,
  cacert,
}:
buildGoModule {
  pname = "homebox";
  version = "0.0.0";
  src = ./.;

  vendorHash = "sha256-xxR0cl0+vDGVoblGSFwvJGZFm5KNp9ZhAchdUl1DbFI=";
  modRoot = "backend";
  # the goModules derivation inherits our buildInputs and buildPhases
  # Since we do pnpm thing in those it fails if we don't explicitly remove them
  overrideModAttrs = _: {
    nativeBuildInputs = [
      go_1_24
      git
      cacert
    ];
    preBuild = "";
  };

  pnpmDeps = pnpm_9.fetchDeps {
    pname = "homebox";
    version = "0.0.0";
    src = ./frontend;
    fetcherVersion = 1;
    hash = "sha256-Pz0USL9/kLPFFBo3uWtZTcgSyuuf3uaFqHTwIJh4i1c=";
  };
  pnpmRoot = "../frontend";

  env.NUXT_TELEMETRY_DISABLED = 1;

  preBuild = ''
    pushd ../frontend

    pnpm build

    popd

    mkdir -p ./app/api/static/public
    cp -r ../frontend/.output/public/* ./app/api/static/public
  '';

  nativeBuildInputs = [
    pnpm_9
    pnpm_9.configHook
    nodejs
  ];

  env.CGO_ENABLED = 0;
  doCheck = false;

  tags = [
    "nodynamic"
  ];

  ldflags = [
    "-s"
    "-w"
    "-extldflags=-static"
  ];
  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp -r $GOPATH/bin/api $out/bin/

    runHook postInstall
  '';
}
