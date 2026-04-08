{
  lib,
  stdenv,
  fetchFromGitHub,
  kernel,
  kernelModuleMakeFlags,
}:

stdenv.mkDerivation {
  pname = "ipu7-drivers";
  version = "unstable-2025-11-12";

  src = fetchFromGitHub {
    owner = "intel";
    repo = "ipu7-drivers";
    rev = "fc335577f95bf6ca3afc706d1ceab8297db4f010";
    hash = "sha256-tRljxzo/WsFBLi/1YqxVRtXpSZzHRqIy3RZ8/heu7mI=";
  };

  ivscSrc = fetchFromGitHub {
    owner = "intel";
    repo = "ivsc-driver";
    rev = "10f440febe87419d5c82d8fe48580319ea135b54";
    hash = "sha256-jc+8geVquRtaZeIOtadCjY9F162Rb05ptE7dk8kuof0=";
  };

  patches = [
    ./0001-media-ipu7-Stop-accessing-streams-configs-directly.patch
  ];

  postPatch = ''
    cp --no-preserve=mode --recursive --verbose \
      $ivscSrc/backport-include \
      $ivscSrc/drivers \
      $ivscSrc/include \
      .
  '';

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
    homepage = "https://github.com/intel/ipu7-drivers";
    description = "IPU7 kernel driver";
    license = licenses.gpl2Only;
    platforms = [ "x86_64-linux" ];
    broken = kernel.kernelOlder "6.12";
  };
}
