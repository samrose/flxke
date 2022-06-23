{
  description = "flxke go lang";

  # Nixpkgs / NixOS version to use.
  inputs.nixpkgs.url = "github:flox/nixpkgs/unstable";
  outputs = {
    self,
    nixpkgs,
  }: let
    # to work with older version of flakes
    lastModifiedDate = self.lastModifiedDate or self.lastModified or "19700101";

    # Generate a user-friendly version number.
    version = builtins.substring 0 8 lastModifiedDate;

    # System types to support.
    supportedSystems = ["x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin"];

    # Helper function to generate an attrset '{ x86_64-linux = f "x86_64-linux"; ... }'.
    forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

    # Nixpkgs instantiated for supported system types.
    nixpkgsFor = forAllSystems (system: import nixpkgs {inherit system;});
  in {
    devShell = forAllSystems (system: let
      pkgs = nixpkgsFor.${system};
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
            let g:mkdp_auto_start = 0
          '';
          packages.package.start = with pkgs.vimPlugins; [
            pkgs.fzf
            vim-go
            vim-markdown
            vim-nix
            vim-parinfer
            tabular
            YouCompleteMe
          ];
        };
        viAlias = true;
        withPython3 = true;
        withRuby = false;
      };
    in
      pkgs.mkShell {
        buildInputs = with pkgs; [alejandra bat bats entr jq go_1_18 gopls gofumpt graphviz neovim-with-config python3 sqlite tmux];
      });
  };
}
