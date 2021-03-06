{ config, lib, pkgs, ... }:

{

  boot.cleanTmpDir = true;

  boot.kernel.sysctl = {
    # Enable all magic sysrq commands (NixOS sets this to 16, which enables sync only)
    "kernel.sysrq" = 1;
  };

  # https://github.com/NixOS/nixpkgs/issues/64965
  environment = {
    etc."ipsec.secrets".text = ''
      include ipsec.d/ipsec.nm-l2tp.secrets
    '';
  };

  users = {
    users.farlion = {
      description = "Florian Peter";
      extraGroups = [ "wheel" "video" "audio" "disk" "networkmanager" "docker" ];
      isNormalUser = true;
      group = "users";
      shell = pkgs.fish;
    };
  };

  networking.networkmanager = {
    enable = true;
    packages = [ pkgs.networkmanager-l2tp ];
  };

  #networking.firewall.allowedTCPPorts = [ 8080 ];

  time.timeZone = "Asia/Singapore";
  i18n.defaultLocale = "en_US.UTF-8";

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio = {
    enable = true;

    # Writes to /etc/pulse/daemon.conf
    daemon.config = {
      default-sample-rate = 48000;
    };

    # NixOS allows either a lightweight build (default) or full build of PulseAudio to be installed.
    # Only the full build has Bluetooth support, so it must be selected here.
    package = pkgs.pulseaudioFull;
  };


  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  services.printing.enable = true;
  services.printing.drivers = [
    pkgs.gutenprint
    pkgs.hplip
  ];

  # limit the amount of logs stored in /var/log/journal
  services.journald.extraConfig = ''
    SystemMaxUse=2G
  '';

  # Default editor for root
  programs.vim.defaultEditor = true;

  # Enable system-wide Yubikey Support
  services.udev.packages = [ pkgs.yubikey-personalization ];

  # Autorandr service
  services.autorandr = {
    enable = true;
    defaultTarget = if (config.networking.hostName == "boar") then "boar" else "sophia";
  };

  # Sysdig + kernel module
  programs.sysdig.enable = true;

  # Steam
  programs.steam.enable = true;

  # Flatpack service
  # https://flatpak.org/setup/NixOS/
  xdg.portal.enable = true;
  services.flatpak.enable = true;

}
