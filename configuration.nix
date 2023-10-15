{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];

  # ====== Network & Time ======

  networking.hostName = "nixos";
  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";

  # ====== Hardware ======

  boot.loader.systemd-boot.enable = true;
  #boot.loader.grub.devices = [ "/dev/sda" ]; # use either grub or systemd-boot
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  # enable audio & display
  services.xserver.enable = true;
  sound.enable = true;

  # keyboard settings for xorg
  services.xserver.layout = "us";
  services.xserver.xkbVariant = "";

  # enable nvidia drivers
  #services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia.modesetting.enable = true;
  hardware.opengl.enable = true;
  hardware.opengl.driSupport32Bit = true;

  # optimize for laptop
  #services.tlp.enable = true;
  #services.power-profiles-daemon.enable = true;
  #boot.kernelParams = [ "mem_sleep_default=deep" ];

  # ignore lid for laptop server
  services.logind.lidSwitch = "ignore";
  services.logind.lidSwitchExternalPower = "ignore";

  # ====== Security ======

  services.openssh.enable = true; # remote login
  security.rtkit.enable = true;
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [

      # WWW
      80    # http
      443   # wget

      # SSH
      22    # local

      # Minecraft
      25565 # vanilla
      25566 # modded
      25569 # testing
      8123  # dynmap
      24454 # voicemod

    ];
    allowedUDPPorts = [
      # Minecraft
      24454
      25565
      25566
      8123
    ];
  };

  # ====== Users ======

  services.getty.autologinUser = "jmhi"; # automatically login

  users.users.jmhi = {
    isNormalUser = true;
    description = "Joseph Isaacs";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [

      # IDE
      alacritty
      jetbrains.rider
      neovim
      tmux
      unityhub

      # Desktop
      firefox
      gnome.nautilus
      nomachine-client
      obs-studio
      protonvpn-gui
      wootility

      # Social
      discord
      lunar-client
      lutris
      prismlauncher
      spotify
      steam

      # Dependencies
      wooting-udev-rules

    ];
  };

  # ====== Root ======

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    
    # Desktop environment
    alacritty firefox lxappearance monitor pavucontrol transmission-qt xterm
    
    # Network
    curl
    git
    wget
    
    # File
    fzf
    man
    neovim
    poppler_utils
    ripgrep
    rmlint
    tree
    unzip
    xclip
    zip
    
    # Process
    btop
    killall
    neofetch
    tmux
    
    # Virtualisation
    bridge-utils
    libvirt
    qemu
    qemu_kvm
    virt-manager
    x11docker
    
    # Coding utils
    cargo rustc rust-analyzer rustfmt
    csslint
    gcc clang clang-tools cmake cmake-format cmake-language-server
    jdk openjdk17-bootstrap jre8
    nixfmt
    nodejs_20
    python3Full

  ];

  environment.shellAliases = {
    nixos-edit="su root -p -c 'cd /etc/nixos/ && nvim ./ -c 'NvimTreeFocus' '";
    nixos-clean="sudo nix-collect-garbage -d && sudo nix profile wipe-history --profile /nix/var/nix/profiles/system --older-than 14d --extra-experimental-features nix-command";
    nixos-evaluate="sudo nix-instantiate '<nixpkgs/nixos>' -A system";
    nixos-switch="sudo nixos-rebuild switch";
    nixos-upgrade="sudo nixos-rebuild switch --upgrade";

    lspacks="nix-store --query --requisites /run/current-system";
    shutdown="echo 'Do not hard shutdown the server without permission.'";
  };

  # ====== Programs ======

  networking.networkmanager.enable = true;

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  users.extraGroups.vboxusers.members = [ "jmhi" ];
  virtualisation.virtualbox = {
    host.enable = true;
    host.enableExtensionPack = true;
    guest.x11 = true;
  };

  # ====== Services ======

  systemd.services = {
    "getty@tty1".enable = false;
    "autovt@tty1".enable = false;
  };

  # SSH
  services.openssh = {
    ports = [ 22 6923 ];
    settings = {
      PermitRootLogin = "yes";
    };
  };

  # Display server
  services.xserver = {
    displayManager.defaultSession = "gnome-xorg";

    desktopManager = { gnome.enable = true; };

    displayManager = {
      gdm.enable = true;
      startx.enable = true; # starting xorg from tty
    };

    windowManager = { i3.enable = true; };

    deviceSection = ''
      Option "TearFree" "true"
      '';
  };

  # Sound server
  hardware.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # Powersave for laptops
  services.tlp.settings = {
    CPU_BOOST_ON_AC = 1;
    CPU_BOOST_ON_BAT = 0;
    CPU_SCALING_GOVERNOR_ON_AC = "performance";
    CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
    START_CHARGE_THRESH_BAT0 = 75;
    STOP_CHARGE_THRESH_BAT0 = 80;
    RESTORE_THRESHOLDS_ON_BAT = 1;
  };

  # ====== Configuration version // Don't change ======
  system.stateVersion = "23.05";
}
