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
          set expandtab
          set tabstop=2
          set softtabstop=2
          set shiftwidth=2
        '';
        packages.package.start = with pkgs.vimPlugins; [
          vim-go
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
    defaultPackage.x86_64-linux = "flxke";
    devShell.x86_64-linux = pkgs.mkShell {
      buildInputs = [neovim-with-config pkgs.alejandra pkgs.bat pkgs.jq];
      shellHook = ''
        export BAT_THEME="Solarized (light)"
      '';
    };
  };
}
