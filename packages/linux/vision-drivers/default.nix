{
  lib,
  stdenv,
  fetchFromGitHub,
  kernel,
  kernelModuleMakeFlags,
}:

stdenv.mkDerivation {
  # Intel CVS kernel module is required so the OV02C10 sensor powers up and
  # gets discovered reliably on Lunar Lake / XPS 13 9350 camera stack.
  pname = "vision-drivers";
  version = "unstable-2026-03-17";

  src = fetchFromGitHub {
    owner = "intel";
    repo = "vision-drivers";
    rev = "a8d772f261bc90376944956b7bfd49b325ffa2f2";
    hash = "sha256-zOvCZKGwOGT9kcJiefzx/duHqR0V8PYhNbqsMHkH1r4=";
  };

  patches = [
    ./0001-intel-cvs-don-t-fail-probe-on-host-identifier.patch
  ];

  nativeBuildInputs = kernel.moduleBuildDependencies;

  makeFlags = kernelModuleMakeFlags ++ [
    "KERNELRELEASE=${kernel.modDirVersion}"
    "KERNEL_SRC=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
  ];

  enableParallelBuilding = true;

  preInstall = ''
    sed -i -e "s,INSTALL_MOD_DIR=,INSTALL_MOD_PATH=$out INSTALL_MOD_DIR=," Makefile
  '';

  installTargets = [ "modules_install" ];

  meta = with lib; {
    homepage = "https://github.com/intel/vision-drivers";
    description = "Intel CVS kernel driver for Lunar Lake camera stack";
    license = licenses.gpl2Only;
    platforms = [ "x86_64-linux" ];
    broken = kernel.kernelOlder "6.7";
  };
}
