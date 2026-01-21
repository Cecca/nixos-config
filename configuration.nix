# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  keycounter,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  nix.settings.experimental-features = ["flakes" "nix-command"];

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
  services.displayManager.gdm.enable = false;
  services.displayManager.sddm = {
    enable = true;
    theme = "catppuccin-mocha-mauve";
  };
  services.desktopManager.gnome.enable = true;

  ##########################################################
  # Hyprland
  programs.hyprland.enable = true;

  # Configure keymap in X11
  services.xserver = {
    xkb.layout = "us";
    xkb.variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.printing.drivers = [pkgs.hplip];

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;

    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  #######################################################################
  # Keyboard remapper
  # https://dev.to/shanu-kumawat/how-to-set-up-kanata-on-nixos-a-step-by-step-guide-1jkc

  # Enable the uinput module
  boot.kernelModules = ["uinput"];

  # Enable uinput
  hardware.uinput.enable = false;
  # Set up udev rules for uinput
  services.udev.extraRules = ''
    KERNEL=="uinput", MODE="0660", GROUP="uinput", OPTIONS+="static_node=uinput"
  '';

  # Ensure the uinput group exists
  users.groups.uinput = {};

  # Add the Kanata service user to necessary groups
  systemd.services.kanata-internalKeyboard.serviceConfig = {
    SupplementaryGroups = [
      "input"
      "uinput"
    ];
  };

  services.kanata = {
    enable = false;
    keyboards = {
      internalKeyboard = {
        devices = [
          "/dev/input/by-path/platform-i8042-serio-0-event-kbd"
        ];
        config = ''
          (defsrc
           caps f h j k l
          )
          (defvar
           tap-time 200
           hold-time 200
          )
          (defalias
           caps (tap-hold 200 200 esc lctl)
           arr (tap-hold $tap-time $hold-time f (layer-toggle arrow))
          )
          (deflayer base
           @caps @arr h j k l
          )
          (deflayer arrow
           _ _ left down up right
          )
        '';
      };
    };
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.matteo = {
    isNormalUser = true;
    description = "Matteo";
    extraGroups = [
      "networkmanager"
      "wheel"
      "input"
      "audio"
      "libvirtd"
      "vboxusers"
      "dialout" # For Arduino board
    ];
    packages = with pkgs; [
      firefox
      vscode-fhs
      darktable
      audacity
      dropbox-cli
      # frescobaldi
      spotify
      zoom-us
      inkscape
      gnome-tweaks
      gedit
      kdePackages.kdenlive
      losslesscut-bin
      mlt
      duckdb
      qbittorrent
      zip
      unzip
      hexyl
      jetbrains-mono
      poppler-utils
      pandoc
      fira-code
      fira-code-symbols
      timidity
      xdg-desktop-portal
      xdg-desktop-portal-gnome
      mpv
      google-chrome
      libreoffice
      slack
      discord
      intel-gpu-tools
      rpi-imager
      scantailor-advanced
      apptainer
      nixos-generators
      gparted
      bitwarden-cli
      calibre
      rnote
      arduino-ide

      # command line utils
      gh
      git-filter-repo
      git-lfs
      ninja
      dust
      ffmpeg-normalize
      ffmpeg
      openssl
      jq
      graphviz
      librsvg
      nil # language server for nix
      jujutsu
      manim
      gemini-cli

      # Gnome extentions
      gnomeExtensions.bing-wallpaper-changer
      gnomeExtensions.appindicator
      gnomeExtensions.tiling-shell
      # gnomeExtensions.tray-icons-reloaded # Crashes when dropbox is launched

      # Other
      xf86_input_wacom
      libwacom
      opentabletdriver
    ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Whitelist some unsecure packages
  nixpkgs.config.permittedInsecurePackages = [
    "electron-25.9.0"
    "python3.12-youtube-dl-2021.12.17"
    # "dotnet-sdk-6.0.428"
  ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs;
    [
      # System
      fira-code
      hplip
      sshpass
      keycounter.packages."x86_64-linux".default

      # Tools
      gnumake
      just
      vim
      neovim
      helix
      wget
      kitty
      obsidian
      zoxide
      eza
      lazygit
      bottom
      bat
      nushell
      nushellPlugins.query
      starship
      fd
      imagemagick
      ghostscript
      pdftk
      sqlite-interactive
      perf
      #coz # causal profiling
      fzf
      tree-sitter
      wl-clipboard
      hdf5
      pkg-config
      uv
      go
      rust-script
      usbutils

      alejandra
      libnotify
      watchexec
      ripgrep
      ruff
      stylua
      lua-language-server
      pyright
      rust-analyzer
      tinymist # typst language server
      (
        catppuccin-sddm.override {
          flavor = "mocha";
          accent = "mauve";
          # font = "Noto Sans";
          # fontSize = "9";
          # background = "${./wallpaper.png}";
          # loginBackground = true;
        }
      )
      # languages
      typst
      marksman
      cmake
      cmakeCurses
      clang
      zig
      zls
      rustup
      cargo-cross
      rust-analyzer
      quarto
      nodejs
      # texliveFull
      mold # faster linker
      jdk25
      python311
      python311Packages.pip

      # Hyprland things
      dunst
      waybar
      polybar
      hyprpaper
      hypridle
      hyprlock
      hyprpolkitagent
      hyprlauncher
      xdg-desktop-portal-hyprland
      hyprland-qt-support
      hyprls
    ]
    ++
    # https://nixos-and-flakes.thiscute.world/best-practices/run-downloaded-binaries-on-nixos#running-downloaded-binaries-on-nixos
    [
      (let
        base = pkgs.appimageTools.defaultFhsEnvArgs;
      in
        pkgs.buildFHSEnv (base
          // {
            name = "fhs";
            targetPkgs = pkgs: (base.targetPkgs pkgs) ++ [pkgs.pkg-config];
            profile = "export FHS=1";
            runScript = "fish";
            extraOutputsToInstall = ["dev"];
          }))
    ];

  virtualisation = {
    podman = {
      enable = true;

      # Create a `docker` alias for podman, to use it as a drop-in replacement
      dockerCompat = true;

      # Required for containers under podman-compose to be able to talk to each other.
      defaultNetwork.settings.dns_enabled = true;
    };
  };
  # virtualisation.docker = {
  #   enable = false;
  #   rootless = {
  #     enable = true;
  #     setSocketVariable = true;
  #   };
  # };

  # virtualisation.virtualbox.host = {
  #   enable = true;
  #   enableKvm = false;
  #   # addNetworkInterface = false;
  # };
  # # without the following, Virtualbox does not work.
  # # see in the future if we can do without it
  # boot.kernelParams = ["kvm.enable_virt_at_load=0"];

  #fonts.packages = with pkgs; [ nerdfonts ];
  fonts.packages = [
    pkgs.nerd-fonts.fira-code
    pkgs.nerd-fonts.jetbrains-mono
    pkgs.nerd-fonts.symbols-only
    pkgs.lato
    pkgs.alegreya
    pkgs.xkcd-font
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

  programs.command-not-found.enable = false;
  programs.nix-index = {
    enable = true;
    enableBashIntegration = true;
    enableFishIntegration = true;
  };

  programs.starship.enable = true;
  programs.git.enable = true;
  programs.fish.enable = true;
  programs.direnv.enable = true;
  programs.steam.enable = true;

  systemd.services.keycounter = {
    enable = true;
    wantedBy = ["default.target"];
    description = "Counts the keypresses";
    serviceConfig = {
      WorkinDirectory = "%h";
      ExecStart = ''
        /run/current-system/sw/bin/keycounter /var/log/keycounter.csv
      '';
    };
  };

  systemd.user.services.notes-count = {
    enable = true;
    wantedBy = ["default.target"];
    description = "Count the words in the Obsidian valut";
    serviceConfig = {
      WorkingDirectory = "%h/Notes";
      Type = "oneshot";
      ExecStart = ''
        /run/current-system/sw/bin/bash -c 'echo $(date --iso-8601=seconds) $(wc --total=only -w -c **/*.md) | tr " " "," >> notes-wordcount.csv'      '';
    };
  };
  systemd.user.timers.notes-count = {
    enable = true;
    wantedBy = ["timers.target"];
    description = "Count words in the obsidian vault every hour";
    timerConfig = {
      OnBootSec = "10min";
      OnCalendar = "hourly";
      Persistent = "true";
      Unit = "notes-count.service";
    };
  };

  # Backup services
  systemd.user.services.backup = {
    enable = true;
    wantedBy = ["default.target"];
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
    wantedBy = ["timers.target"];
    description = "Run the backup every hour";
    timerConfig = {
      OnBootSec = "15min";
      OnCalendar = "hourly";
      Persisten = "true";
    };
  };

  # Dropbox service
  systemd.user.services.dropbox = {
    description = "Dropbox";
    wantedBy = ["graphical-session.target"];
    environment = {
      QT_PLUGIN_PATH = "/run/current-system/sw/" + pkgs.qt5.qtbase.qtPluginPrefix;
      QML2_IMPORT_PATH = "/run/current-system/sw/" + pkgs.qt5.qtbase.qtQmlPrefix;
    };
    serviceConfig = {
      ExecStart = "${pkgs.dropbox.out}/bin/dropbox";
      ExecReload = "${pkgs.coreutils.out}/bin/kill -HUP $MAINPID";
      KillMode = "control-group"; # upstream recommends process
      Restart = "on-failure";
      PrivateTmp = true;
      ProtectSystem = "full";
      Nice = 10;
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
  networking.firewall = {
    allowedTCPPorts = [17500];
    allowedUDPPorts = [17500];
  };
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
