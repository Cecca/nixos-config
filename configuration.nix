# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, pkgs-unstable, ... }:

{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  nix.settings.experimental-features = [ "flakes" "nix-command" ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Rome";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "it_IT.UTF-8";
    LC_IDENTIFICATION = "it_IT.UTF-8";
    LC_MEASUREMENT = "it_IT.UTF-8";
    LC_MONETARY = "it_IT.UTF-8";
    LC_NAME = "it_IT.UTF-8";
    LC_NUMERIC = "it_IT.UTF-8";
    LC_PAPER = "it_IT.UTF-8";
    LC_TELEPHONE = "it_IT.UTF-8";
    LC_TIME = "it_IT.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.matteo = {
    isNormalUser = true;
    description = "Matteo";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      firefox
      darktable
      audacity
      frescobaldi
      musescore
      spotify
      pkgs-unstable.zoom-us
      inkscape
      gnome.gnome-tweaks
      tor-browser
      youtube-dl
      transmission-gtk

      # command line utils
      gh

      # Gnome extentions
      gnomeExtensions.bing-wallpaper-changer
      gnomeExtensions.tray-icons-reloaded
    ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Whitelist some unsecure packages
  nixpkgs.config.permittedInsecurePackages = [
    "electron-25.9.0"
  ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # System
    fira-code
    hplip

    # Tools
    gnumake
    gcc12
    just
    vim
    neovim
    wget
    pkgs-unstable.wezterm
    obsidian
    zoxide
    eza
    lazygit
    bottom
    bat
    nushell
    starship
    fd
    imagemagick
    ghostscript

    alejandra
    libnotify
    watchexec
    ripgrep

    # languages
    rustup
    rust-analyzer
    micromamba
    quarto
    nodejs
    texlive.combined.scheme-full
    pkgs-unstable.mold # faster linker
    nodejs_21
    jdk
    python3
  ];

  programs.bash = {
    blesh.enable = false;
    undistractMe.enable = false;
    # start Fish if the parent shell is not already fish.
    # from https://nixos.wiki/wiki/Fish
    interactiveShellInit = ''
      if [[ $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]
      then
        shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
        exec ${pkgs.fish}/bin/fish $LOGIN_OPTION
      fi
    '';
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  programs.starship.enable = true;
  programs.git.enable = true;
  programs.fish.enable = true;
  programs.direnv.enable = true;
  programs.steam.enable = true;

  # Backup services
  systemd.user.services.backup = {
    enable = true;
    wantedBy = [ "default.target" ];
    description = "Backup the home directory using linux-timemachine";
    unitConfig = {
      ConditionPathIsDirectory = "/var/run/media/matteo/matteo-backup/backup";
    };
    serviceConfig = {
      WorkinDirectory = "%h";
      Type = "oneshot";
      ExecStart = ''/usr/local/bin/timemachine /home/matteo/ /var/run/media/matteo/matteo-backup/backup -- --exclude-from=%h/.config/linux-timemachine/exclude.txt'';

    };
  };
  systemd.user.timers.backup = {
    enable = true;
    wantedBy = [ "timers.target" ];
    description = "Run the backup every hour";
    timerConfig = {
      OnBootSec = "15min";
      OnCalendar = "hourly";
      Persisten = "true";
    };
  };


  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?

}
