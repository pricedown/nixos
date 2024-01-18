{ config, pkgs, ... }:

let
  unstable = import 
  (builtins.fetchTarball https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz)

# reuse the current configuration
{ config = config.nixpkgs.config; };
in
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
  boot.loader.efi.canTouchEfiVariables = true;

  # enable audio & display
  services.xserver.enable = true;
  sound.enable = true;

  # keyboard settings for xorg
  services.xserver.layout = "us";
  services.xserver.xkbVariant = "";
  services.xserver.libinput.enable = false;

  # monitor settings
  services.xserver.dpi = 215;
  environment.variables.GDK_SCALE = "0.5";

  # enable nvidia drivers
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia.modesetting.enable = true;
  hardware.opengl.enable = true;
  hardware.opengl.driSupport32Bit = true;

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;
  
  # optimize battery for laptop
  services.tlp.enable = true;
  services.power-profiles-daemon.enable = false;
  # boot.kernelParams = [ "mem_sleep_default=deep" ];

  # services.xserver.monitorSection = ''
  #   Modeline "1920x1440R" 703.75  1920 2096 2304 2688  1440 1443 1447 1588 -hsync +vsync
  # '';
  services.xserver.deviceSection = ''
    Option "TearFree" "true"
    Option "ModeValidation" "AllowNonEdidModes"
  '';

  # ====== Security ======

  # remote login
  services.openssh = {
    enable = false;
    settings.PermitRootLogin = "no";
    ports = [ 22 ]; # ensure that the firewall allows these!
  };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ ];
    allowedUDPPorts = [ ];
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
      dia
      godot_4
      jetbrains-toolbox
      neovim
      neovim-remote
      starship
      tmux
      unityhub
      zellij

      # Desktop
      anydesk
      autokey
      calibre
      chkrootkit
      firefox
      gnome.nautilus
      nomachine-client
      obs-studio
      protonvpn-gui
      tor-browser-bundle-bin
      unstable.teamviewer

      # Social
      discord
      lunar-client
      signal-desktop
      spotify
    
      # Games
      prismlauncher
      steam
      lutris
      unstable.vinegar
      unstable.r2modman
      wesnoth
      
      # Settings
      wootility
      wooting-udev-rules
      bluez
      bluez-tools

    ];
  };

  # ====== Root ======
  
  nixpkgs.config.permittedInsecurePackages = [ 
      "electron-25.9.0"
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  nixpkgs.config = {
    allowUnfree = true;
    vivaldi = {
        proprietaryCodecs = true;
        enableWideVine = true;
    };
  };
  environment.systemPackages = with pkgs; [

    # Desktop environment
    pkgs.dunst libnotify xdg-utils
    jetbrains-mono font-awesome corefonts
    alacritty firefox lxappearance monitor pavucontrol transmission-qt xterm kitty xorg.xwininfo xorg.libxcvt linux-wallpaperengine xwallpaper xorg.xeyes
    raylib mesa
    pkg-config
    wayland
    libxkbcommon
    wayland-protocols
    xorg.libX11.dev
    xorg.libX11
    gnumake
    xorg.libXcursor.dev 
    xorg.libXrandr.dev 
    xorg.libXft.dev
    xorg.libXft
    xorg.libXinerama.dev
    xorg.libXinerama
    xorg.libXi.dev
    libGL.dev
    clang
    libclang.dev
    libclang.lib
    clangStdenv
    glfw
    
    # Hyprland
    waylock dbus dunst gtk3 hyprland-protocols hyprpaper kitty libnotify feh rofi-wayland swww wofi  wl-clipboard wl-clipboard-x11 xorg.libxcb xclip grim slurp sway-contrib.grimshot waypaper
    (waybar.overrideAttrs (oldAttrs: {
        mesonFlags = oldAttrs.mesonFlags ++ [" -Dexperimental=true "];
      })
    )

    # Network
    curl
    gh
    git
    inetutils
    wget

    # File
	lazygit
    bat
    chkrootkit
    exiftool
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

    # Process
    btop
    gdb
    ghidra
    killall
    neofetch
    ocamlPackages.hxd
    pstree
    scanmem
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
    rustup cargo rustc rust-analyzer rustfmt
    csslint
    msbuild csharp-ls mono dotnet-runtime_8 dotnet-sdk dotnet-sdk_8
    gcc clang clang-tools cmake cmake-format cmake-language-server unstable.emscripten
    gnumake
    jdk17 jdk
    nixfmt
    nodejs_20
    python3Full
    lua-language-server
  ];

  fonts.packages = with pkgs; [
    (nerdfonts.override { fonts = [
	  "JetBrainsMono"
	  "FiraCode" 
      ]; })
	  font-awesome
      cascadia-code
      redhat-official-fonts
  ];

  environment.shellAliases = {
    nixos="su root -p -c 'cd /etc/nixos/ && nvim ./ -c 'NvimTreeFocus' '";
    nixos-clean="sudo nix-collect-garbage -d && sudo nix profile wipe-history --profile /nix/var/nix/profiles/system --older-than 14d --extra-experimental-features nix-command";
    nixos-evaluate="sudo nix-instantiate '<nixpkgs/nixos>' -A system";
    nixos-switch="sudo nixos-rebuild switch";
    nixos-upgrade="sudo nixos-rebuild switch --upgrade";

    lspacks="nix-store --query --requisites /run/current-system";
  };

  # TODO put in *user* session vars
  environment.sessionVariables = {
    # For Hyprland WM
    NIXOS_OZONE_WL = "1";
    WLR_NO_HARDWARE_CURSORS = "1";
    WLR_RENDERER_ALLOW_SOFTWARE = "1 Hyprland";

    LIBCLANG_PATH="${pkgs.libclang.lib}/lib";
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
    displayManager.defaultSession = "hyprland";

    desktopManager = { 
        gnome.enable = false; 
        xterm.enable = false;
    };

    displayManager = {
      gdm.enable = true;
      startx.enable = true; # starting xorg from tty
    };

    windowManager = { 
      i3 = { 
        enable = true; 
        extraPackages = with pkgs; [
          dmenu
            i3status 
            i3lock 
            i3blocks 
        ];
      };
    };
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
 
  # Antivirus
  services.clamav = {
    daemon.enable = true;
    updater.enable = true;
  };

  services.teamviewer.enable = true;

  # ====== Configuration version // Don't change ======
  system.stateVersion = "23.05";
}
