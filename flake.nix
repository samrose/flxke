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
    devShell.x86_64-linux = pkgs.mkShell {
      buildInputs = [neovim-with-config pkgs.alejandra pkgs.bat pkgs.jq pkgs.nix-eval-jobs];
      shellHook = ''
        export LOCALE_ARCHIVE=/usr/lib/locale/locale-archive
        export BAT_THEME="Solarized (light)"
      '';
    };
  };
}
