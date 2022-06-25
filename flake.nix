{
  description = "flxke elixir-phoenix";

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
        alchemist-vim
        vim-elixir
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

      basePackages = with pkgs; [alejandra bat bats beam.packages.erlangR25.elixir_1_13 entr jq postgresql_14 graphviz neovim-with-config python3 sqlite tmux];

      hooks = ''

        mkdir -p .nix-mix .nix-hex .nix-bin
        export MIX_HOME=$PWD/.nix-mix
        export HEX_HOME=$PWD/.nix-mix
        export NIX_BIN_PATH=$PWD/.nix-bin
        export MIX_PATH="${pkgs.beam.packages.erlang.hex}/lib/erlang/lib/hex/ebin"
        export PATH=$MIX_HOME/bin:$HEX_HOME/bin:$NIX_BIN_PATH:$PATH

        # Install ecs-deploy
        #local PATH_TO_ECS_DEPLOY=$NIX_BIN_PATH/ecs-deploy
        #if [ -f $PATH_TO_ECS_DEPLOY ]; then
        #  echo "ecs-deploy already installed at $PATH_TO_ECS_DEPLOY"
        #else
        #  echo "Installing ecs-deploy..."
        #  curl -o $PATH_TO_ECS_DEPLOY \
        #    https://raw.githubusercontent.com/silinternational/ecs-deploy/4d1c5fca5a0bde677aff7af5a711c1e92279b622/ecs-deploy \
        #    && chmod +x $NIX_BIN_PATH/ecs-deploy
        #fi

        export LANG=en_US.utf-8
        #export ERL_AFLAGS="-kernel shell_history enabled"

        # Postgres
        export PGDATA="$PWD/db"
        export PG_LOGFILE="$PGDATA/server.log"
        export POOL_SIZE=15
        export PORT=4000

        export DB_USERNAME=postgres
        export DB_PASSWORD=postgres
        export DB_HOST=localhost
        export DB_NAME=db
        export DB_PORT=5432

        if ! pg_ctl status
          then pg_ctl -l "$PG_LOGFILE" start
        fi
      '';
    in
      pkgs.mkShell {
        buildInputs = basePackages;
        shellHook = hooks;
      });
  };
}
