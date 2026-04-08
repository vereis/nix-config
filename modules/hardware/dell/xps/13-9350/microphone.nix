{ pkgs, ... }:

{
  systemd.services.xps13-9350-rt714-mic-workaround = {
    description = "Apply RT714 SoundWire microphone mixer workaround";
    wantedBy = [ "multi-user.target" ];
    after = [ "sound.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      for _ in $(seq 1 30); do
        if ${pkgs.alsa-utils}/bin/amixer -c 0 sset "rt714 ADC 22 Mux" "DMIC2" >/dev/null 2>&1 \
          && ${pkgs.alsa-utils}/bin/amixer -c 0 sset "rt714 ADC 23 Mux" "DMIC2" >/dev/null 2>&1 \
          && ${pkgs.alsa-utils}/bin/amixer -c 0 sset "rt714 ADC 24 Mux" "DMIC2" >/dev/null 2>&1 \
          && ${pkgs.alsa-utils}/bin/amixer -c 0 sset "rt714 ADC 25 Mux" "DMIC2" >/dev/null 2>&1 \
          && ${pkgs.alsa-utils}/bin/amixer -c 0 sset "rt714 FU06" cap 63 on >/dev/null 2>&1 \
          && ${pkgs.alsa-utils}/bin/amixer -c 0 sset "rt714 FU0A" cap 63 on >/dev/null 2>&1 \
          && ${pkgs.alsa-utils}/bin/amixer -c 0 sset "rt714 FU0C Boost" 2 >/dev/null 2>&1 \
          && ${pkgs.alsa-utils}/bin/amixer -c 0 sset "rt714 FU0E Boost" 2 >/dev/null 2>&1; then
          exit 0
        fi
        sleep 1
      done

      exit 0
    '';
  };
}
