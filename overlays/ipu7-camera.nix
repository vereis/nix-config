_: final: prev:
let
  # XPS 13 9350 webcam support depends on Intel IPU7 userspace pieces that are
  # not fully available in our base nixpkgs snapshot yet.
  # This overlay provides those packages globally so hardware modules can consume them.

  # Camera HAL userspace plugin used by the Intel camera stack.
  ipu7CameraHalPkg =
    {
      lib,
      stdenv,
      fetchFromGitHub,
      cmake,
      pkg-config,
      expat,
      ipu7-camera-bins,
      jsoncpp,
      libtool,
      gst_all_1,
      libdrm,
      ipuVersion ? "ipu7x",
    }:
    let
      ipuTarget =
        {
          ipu7x = "ipu_lnl";
          ipu75xa = "ipu_lnl";
        }
        .${ipuVersion};
    in
    stdenv.mkDerivation {
      pname = "${ipuVersion}-camera-hal";
      version = "unstable-2025-01-15";

      src = fetchFromGitHub {
        owner = "intel";
        repo = "ipu7-camera-hal";
        rev = "431ff3f46ef821458d973390c8a88687637290c2";
        hash = "sha256-/bSH+NJgVQ4HoW6yDlZGyg9EqTs+t0S3ZibVwl7IWf4=";
      };

      patches = [
        ./ipu7-camera-hal-uint32.patch
      ];

      nativeBuildInputs = [
        cmake
        pkg-config
      ];

      cmakeFlags = [
        "-DCMAKE_BUILD_TYPE=Release"
        "-DCMAKE_INSTALL_PREFIX=${placeholder "out"}"
        "-DCMAKE_INSTALL_LIBDIR=lib"
        "-DCMAKE_INSTALL_INCLUDEDIR=include"
        "-DCMAKE_POLICY_VERSION_MINIMUM=3.5"
        "-DBUILD_CAMHAL_ADAPTOR=ON"
        "-DBUILD_CAMHAL_PLUGIN=ON"
        "-DIPU_VERSIONS=${ipuVersion}"
        "-DUSE_STATIC_GRAPH=ON"
        "-DUSE_STATIC_GRAPH_AUTOGEN=ON"
      ];

      NIX_CFLAGS_COMPILE = [ "-Wno-error" ];

      enableParallelBuilding = true;

      buildInputs = [
        expat
        ipu7-camera-bins
        jsoncpp
        libtool
        gst_all_1.gstreamer
        gst_all_1.gst-plugins-base
        libdrm
      ];

      postPatch = ''
        substituteInPlace src/platformdata/JsonParserBase.h \
          --replace-fail '<jsoncpp/json/json.h>' '<json/json.h>'
      '';

      postInstall = ''
        mkdir -p $out/include/${ipuTarget}/
        cp -r $src/include $out/include/${ipuTarget}/libcamhal
      '';

      postFixup = ''
        for lib in $out/lib/*.so; do
          patchelf --add-rpath "${ipu7-camera-bins}/lib" $lib
        done
      '';

      passthru = {
        inherit ipuVersion ipuTarget;
      };

      meta = with lib; {
        description = "HAL for processing of images in userspace";
        homepage = "https://github.com/intel/ipu7-camera-hal";
        license = licenses.asl20;
        platforms = [ "x86_64-linux" ];
      };
    };

  # GStreamer source plugin that exposes the Intel MIPI camera stream.
  icamerasrcIpuPkg =
    {
      lib,
      stdenv,
      fetchFromGitHub,
      autoreconfHook,
      pkg-config,
      gst_all_1,
      ipuCameraHal,
      libdrm,
      libva,
      apple-sdk_gstreamer ? null,
    }:
    stdenv.mkDerivation {
      pname = "icamerasrc-${ipuCameraHal.ipuVersion}";
      version = "unstable-2024-11-29";

      src = fetchFromGitHub {
        owner = "intel";
        repo = "icamerasrc";
        rev = "ee8526451ca1bb4957702de2f46138b63151f34c";
        hash = "sha256-GX67+A77/YQBwqqbBiDHrkiKb2CMAO5CJTwm1XyQOkg=";
      };

      nativeBuildInputs = [
        autoreconfHook
        pkg-config
      ];

      preConfigure = ''
        export CHROME_SLIM_CAMHAL=ON
      '';

      configureFlags = [
        "--enable-gstdrmformat=yes"
      ];

      buildInputs = [
        gst_all_1.gstreamer
        gst_all_1.gst-plugins-base
        gst_all_1.gst-plugins-bad
        ipuCameraHal
        libdrm
        libva
      ]
      ++ lib.optionals stdenv.hostPlatform.isDarwin [ apple-sdk_gstreamer ];

      NIX_CFLAGS_COMPILE = [
        "-Wno-error"
        "-I${gst_all_1.gst-plugins-base.dev}/include/gstreamer-1.0"
      ];

      enableParallelBuilding = true;

      passthru = {
        inherit (ipuCameraHal) ipuVersion;
      };

      meta = with lib; {
        description = "GStreamer plugin for Intel MIPI cameras on IPU7";
        homepage = "https://github.com/intel/icamerasrc/tree/icamerasrc_slim_api";
        license = licenses.lgpl21Plus;
        platforms = [ "x86_64-linux" ];
      };
    };
in
{
  # Firmware + binary userspace libs required by Intel's IPU7 stack.
  ipu7-camera-bins = prev.stdenv.mkDerivation {
    pname = "ipu7-camera-bins";
    version = "unstable-2025-01-15";

    src = prev.fetchFromGitHub {
      owner = "intel";
      repo = "ipu7-camera-bins";
      rev = "f4a353c7c2f0dc98416cd847a74724e8d6e07519";
      hash = "sha256-4LOFOIdBSMITNA1RtH8TDwPd+r/0lyTA6RBPeD0exO8=";
    };

    nativeBuildInputs = [
      prev.autoPatchelfHook
      (prev.lib.getLib prev.stdenv.cc.cc)
      prev.expat
      prev.zlib
    ];

    installPhase = ''
      runHook preInstall

      mkdir -p $out
      cp --no-preserve=mode --recursive \
        lib \
        include \
        $out/

      runHook postInstall
    '';

    postFixup = ''
      for lib in $out/lib/lib*.so.*; do
        lib=''${lib##*/}
        target=$out/lib/''${lib%.*}
        if [ ! -e "$target" ]; then
          ln -s "$lib" "$target"
        fi
      done

      for pcfile in $out/lib/pkgconfig/*.pc; do
        substituteInPlace $pcfile \
          --replace 'prefix=/usr' "prefix=$out"
      done
    '';

    meta = with prev.lib; {
      description = "IPU firmware and proprietary image processing libraries";
      homepage = "https://github.com/intel/ipu7-camera-bins";
      license = licenses.issl;
      sourceProvenance = with sourceTypes; [ binaryFirmware ];
      platforms = [ "x86_64-linux" ];
    };
  };

  # HAL variants consumed by different IPU7 targets.
  ipu7-camera-hal = prev.callPackage ipu7CameraHalPkg { };
  ipu7x-camera-hal = prev.callPackage ipu7CameraHalPkg { ipuVersion = "ipu7x"; };
  ipu75xa-camera-hal = prev.callPackage ipu7CameraHalPkg { ipuVersion = "ipu75xa"; };

  # icamerasrc variants used by v4l2-relayd and PipeWire paths.
  icamerasrc-ipu7x = prev.callPackage icamerasrcIpuPkg {
    ipuCameraHal = final.ipu7x-camera-hal;
  };

  icamerasrc-ipu75xa = prev.callPackage icamerasrcIpuPkg {
    ipuCameraHal = final.ipu75xa-camera-hal;
  };
}
