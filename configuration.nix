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
  #hardware.nvidia.modesetting.enable = true;
  #hardware.opengl.enable = true;
  #hardware.opengl.driSupport32Bit = true;

  # optimize battery for laptop
  #services.tlp.enable = true;
  #services.power-profiles-daemon.enable = false;
  #boot.kernelParams = [ "mem_sleep_default=deep" ];

  # ignore lid for laptop server
  #services.logind.lidSwitch = "ignore";
  #services.logind.lidSwitchExternalPower = "ignore";

  # ====== Security ======

  # remote login
  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "yes";
    ports = [ 22 ]; # ensure that the firewall allows these!
  };

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

  security.rtkit.enable = true;
  
  # ====== Users ======

  services.getty.autologinUser = "jmhi"; # automatic login

  users.users.jmhi = {
    isNormalUser = true;
    description = "Joseph Isaacs";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [

      # IDE
      alacritty
      godot_4
      jetbrains.rider
      neovim
      neovim-remote
      tmux
      unityhub
      zellij

      # Desktop
      anydesk
      calibre
      firefox
      gnome.nautilus
      nomachine-client
      obs-studio
      protonvpn-gui
      tor-browser-bundle-bin
      wootility

      # Social
      discord
      lunar-client
      lutris
      prismlauncher
      signal-desktop
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

    # Desktop
    alacritty firefox lxappearance monitor pavucontrol transmission-qt xterm kitty
	
    # Hyprland
    waylock dbus dunst libnotify gtk3 hyprland-protocols hyprland-share-picker hyprpaper kitty rofi-wayland swww wofi wl-clipboard wl-clipboard-x11 xorg.libxcb xclip (waybar.overrideAttrs (oldAttrs: { mesonFlags = oldAttrs.mesonFlags ++ [" -Dexperimental=true "]; }))

    # Network
    curl
    gh
    git
    wget

    # Files
    bat
    ffmpeg
    fzf
    lf
    man
    neovim
    neovim-remote
    poppler_utils
    ripgrep
    rmlint
    tree
    unzip
    xclip
    zip

    # Processes
    btop
    killall
    neofetch
    tmux
    tmux-sessionizer
    zellij

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
    dotnet-runtime_8
    dotnet-sdk_8
    gcc clang clang-tools cmake cmake-format cmake-language-server
    gnumake
    jdk openjdk17-bootstrap jre8
    mono5
    nixfmt
    nodejs_20
    python3Full

  ];

  fonts.fonts = with pkgs; [
    (nerdfonts.override { fonts = [ 
	"JetBrainsMono" 
	"FiraCode" ]; }) 
	font-awesome
  ];

  environment.shellAliases = {
    nixos="su root -p -c 'cd /etc/nixos/ && nvim ./ -c 'NvimTreeFocus' '";
    nixos-clean="sudo nix-collect-garbage -d && sudo nix profile wipe-history --profile /nix/var/nix/profiles/system --older-than 14d --extra-experimental-features nix-command";
    nixos-evaluate="sudo nix-instantiate '<nixpkgs/nixos>' -A system";
    nixos-switch="sudo nixos-rebuild switch";
    nixos-upgrade="sudo nixos-rebuild switch --upgrade";

    lspacks="nix-store --query --requisites /run/current-system";
    shutdown="echo 'Do not hard shutdown the server without permission.'";
  };

  environment.sessionVariables = {
    # For Hyprland WM
    WLR_NO_HARDWARE_CURSORS = "1";
    WLR_RENDERER_ALLOW_SOFTWARE = "1 Hyprland";
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

  # Display server
  services.xserver = {
    displayManager.defaultSession = "gnome-xorg";

    desktopManager = { gnome.enable = true; };

    displayManager = {
      gdm.enable = true;
      startx.enable = true; # starting xorg from tty
    };

    windowManager = { 
      i3.enable = true; 
    };

    deviceSection = ''
      Option "TearFree" "true"
      '';
  };
  
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # Sound server
  hardware.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    jack.enable = true;
    pulse.enable = true;
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

  # XDG for compatibility
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  # ====== Configuration version // Don't change ======
  system.stateVersion = "23.05";
}
