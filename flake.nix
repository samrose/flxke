{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/master";
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
      paths = [neovim-with-config pkgs.alejandra pkgs.bat pkgs.jq];
    };
    apps.x86_64-linux.default = {
      type = "app";
      program =
        (pkgs.writeShellApplication {
          name = "activate";
          text = ''
            export BAT_THEME="Solarized (light)"
          '';
        })
        .outPath
        + "/bin/activate";
    };
  };
}
