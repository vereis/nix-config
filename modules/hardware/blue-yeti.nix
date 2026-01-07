{
  lib,
  config,
  pkgs,
  ...
}:

let
  inherit (lib) mkOption mkIf types;
  cfg = config.modules.hardware.blue-yeti;
in
{
  options.modules.hardware.blue-yeti = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable Blue Yeti microphone support with automatic USB reset on boot.";
    };
  };

  config = mkIf cfg.enable {
    # Blue Yeti USB audio interface sometimes doesn't initialize properly on boot.
    # This udev rule performs an "unbind/bind" cycle to reset the USB device.
    services.udev.extraRules = ''
      # Blue Yeti Microphone (Logitech Blue Microphones)
      # Vendor ID: 046d, Product ID: 0ab7
      # Reset the USB device on detection to ensure proper initialization
      ACTION=="add", SUBSYSTEM=="usb", ATTRS{idVendor}=="046d", ATTRS{idProduct}=="0ab7", \
        RUN+="${pkgs.bash}/bin/bash -c 'echo $kernel > /sys/bus/usb/drivers/usb/unbind; sleep 1; echo $kernel > /sys/bus/usb/drivers/usb/bind'"
    '';

    # Also handle suspend/resume by resetting the Blue Yeti after waking up
    systemd.services.blue-yeti-resume = {
      description = "Reset Blue Yeti microphone after resume from suspend";
      after = [ "suspend.target" ];
      wantedBy = [ "suspend.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = pkgs.writeShellScript "reset-blue-yeti" ''
          # Find the Blue Yeti device and reset it
          for device in /sys/bus/usb/devices/*; do
            if [ -f "$device/idVendor" ] && [ -f "$device/idProduct" ]; then
              vendor=$(cat "$device/idVendor")
              product=$(cat "$device/idProduct")
              if [ "$vendor" = "046d" ] && [ "$product" = "0ab7" ]; then
                devname=$(basename "$device")
                echo "Resetting Blue Yeti: $devname"
                echo "$devname" > /sys/bus/usb/drivers/usb/unbind 2>/dev/null || true
                sleep 1
                echo "$devname" > /sys/bus/usb/drivers/usb/bind 2>/dev/null || true
              fi
            fi
          done
        '';
      };
    };
  };
}
