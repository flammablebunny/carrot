{
  lib,
  craneLib,
  pkg-config,
  wayland-scanner,
  vulkan-loader,
  vulkan-headers,
  wayland,
  wayland-protocols,
  libdrm,
  libinput,
  seatd,
  libxkbcommon,
  pixman,
  udev,
}:
let
  version = "0.0.1";

  src = lib.cleanSourceWith {
    src = ./.;
    filter = path: type:
      (craneLib.filterCargoSources path type)
      || (lib.hasSuffix ".xml" path);
  };

  commonArgs = {
    inherit src;
    pname = "carrot";
    inherit version;

    nativeBuildInputs = [
      pkg-config
      wayland-scanner
    ];

    buildInputs = [
      vulkan-loader
      vulkan-headers
      wayland
      wayland-protocols
      libdrm
      libinput
      seatd
      libxkbcommon
      pixman
      udev
    ];

    LD_LIBRARY_PATH = lib.makeLibraryPath [ vulkan-loader ];
  };
in
craneLib.buildPackage (commonArgs // {
  cargoArtifacts = craneLib.buildDepsOnly commonArgs;

  postInstall = ''
    # Wayland session desktop entry
    mkdir -p $out/share/wayland-sessions
    cat > $out/share/wayland-sessions/carrot.desktop << EOF
    [Desktop Entry]
    Name=Carrot
    Comment=A pure Rust tiling Wayland compositor
    Exec=$out/bin/carrot
    Type=Application
    EOF
  '';

  meta = {
    description = "A pure Rust tiling Wayland compositor with Vulkan rendering";
    license = lib.licenses.gpl3;
    platforms = [ "x86_64-linux" "aarch64-linux" ];
    mainProgram = "carrot";
  };
})
