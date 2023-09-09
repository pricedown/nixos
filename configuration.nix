# configuration.nix

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];


  hardware = {
    opengl.enable = true;
  };

  boot.loader = {
    systemd-boot.enable = true;
  };

  networking = {
    hostName = "jmhi-nixos";
    networkmanager.enable = true;

    # firewall.enable = false;
    # firewall.allowedTCPPorts = [ ... ];
    # firewall.allowedUDPPorts = [ ... ];
  };

  # Locale
  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # NVIDIA drivers
  hardware.nvidia = {
	  modesetting.enable = true;
	  prime = {
		  offload = {
			enable = true;
		  	enableOffloadCmd = true;
		  };
		  nvidiaBusId = "PCI:1:0:0";
		  intelBusId = "PCI:0:2:0";
	  };	
  };
  programs.hyprland.nvidiaPatches = true;
  services.xserver.videoDrivers = [ "nvidia" ];

  # -------------------
  # Users & Environment
  # -------------------

  nixpkgs.config.allowUnfree = true;

  users.users.jmhi = {
    isNormalUser = true;
    description = "Joseph Isaacs";
    extraGroups = [ "networkmanager" "wheel" ];

    packages = with pkgs; [

      # Tools
      protonvpn-gui

      # Firmware
      wootility
      wooting-udev-rules
      
      # Media
      discord
      spotify

      # Gaming
      lunar-client
      lutris
      prismlauncher
      steam
    ];

  };

  environment.systemPackages = with pkgs; [
     # Hyprland
     dbus
     dunst
     gtk3
     hyprland-protocols
     hyprland-share-picker
     hyprpaper
     kitty
     libnotify
     rofi-wayland
     swww
     wofi
     xdg-desktop-portal-hyprland
     wl-clipboard
     wl-clipboard-x11
     xclip

     # waybar
     (waybar.overrideAttrs (oldAttrs: {
         mesonFlags = oldAttrs.mesonFlags ++ [" -Dexperimental=true "];
       })
     )

     # Desktop Apps
     alacritty
     firefox
     flameshot
     lxappearance
     monitor
     pavucontrol
     transmission-qt

     # Terminal Apps
     btop
     curl
     git
     killall
     man
     neofetch
     neovim
     ripgrep
     rmlint
     tmux
     tree
     unzip
     wget
     xterm
     # browsh with vim
    #(callPackage (fetchgit {
    #  url = "https://www.github.com/browsh-org/browsh.git";
    #  ref = "vim-mode-branch";
    #}) {})

    # Virtualization
     virtualbox
     bridge-utils
     libvirt
     qemu
     qemu_kvm
     virt-manager

     # Code
     nixfmt
     gcc clang clang-tools cmake cmake-format cmake-language-server
     cargo rustc rust-analyzer rustfmt
     python3Full
     jdk openjdk17-bootstrap jre8
     csslint
     nodejs_20

    # Theming
    jetbrains-mono
    font-awesome
  ];

  environment.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS = "1";
    NIXOS_OZONE_WL = "1";
    EDITOR = "nvim";
    WLR_RENDERER_ALLOW_SOFTWARE = "1 Hyprland";
  };

  # --------
  # Programs
  # --------

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # Boilerplate they said I might need idk
  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # --------
  # Services
  # --------

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  services.openssh.enable = true;

  # Enable sound with pipewire
  sound.enable = true;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable =  true;
    jack.enable = true;
  };

  services.xserver = {
    enable = true;
    layout = "us";
    xkbVariant = "";

    deviceSection = ''
      Option "TearFree" "true"
    '';

    displayManager = {
      gdm.enable = true;
      gdm.wayland = true;
    };
  };

  services.tlp = {
	  enable = true;
	  settings = {
		  START_CHARGE_THRESH_BAT0 = 75;
		  STOP_CHARGE_THRESH_BAT0 = 80;
		  RESTORE_THRESHOLDS_ON_BAT = 1;
	  };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

}
