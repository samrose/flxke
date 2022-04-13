{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };
  outputs = {
    self,
    nixpkgs,
  }: let
    pkgs = nixpkgs.legacyPackages.x86_64-linux;
    neovim-with-config = pkgs.neovim.override {
      configure = {
        customRC = ''
                 set title
                 set nu
                 autocmd BufWritePre * :%s/\s\+$//e
                 set ts=4
          set noet
        '';
        packages.package.start = with pkgs.vimPlugins; [
          vim-nix
          vim-parinfer
          YouCompleteMe
        ];
      };

      viAlias = true;
      withPython3 = true;
      withRuby = false;
    };
  in {
    packages.x86_64-linux.default = pkgs.buildEnv {
      name = "flxke";
      paths = [neovim-with-config pkgs.alejandra pkgs.asciinema pkgs.bat pkgs.bats pkgs.entr pkgs.fswatch pkgs.fzf pkgs.jq pkgs.shfmt];
    };
    apps.x86_64-linux.default = {
      type = "app";
      program =
        (pkgs.writeShellApplication {
          name = "activate";
          text = ''
                   export BAT_THEME="Solarized (light)"
            export LOCALE_ARCHIVE=/usr/lib/locale/locale-archive
          '';
        })
        .outPath
        + "/bin/activate";
    };
  };
}
