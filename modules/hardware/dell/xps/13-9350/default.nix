{ ... }:

{
  imports = [
    ./camera-ipu7.nix
    ./microphone.nix
  ];

  boot.kernelParams = [
    "xe.enable_psr=0" # Disable PSR, which causes screen flicker/glitches.
    "snd_intel_dspcfg.dsp_driver=3" # Force SOF audio path so internal mic works.
  ];
}
