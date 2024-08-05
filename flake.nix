{
  outputs =
    { self, nixpkgs }:
    {
      packages = builtins.mapAttrs (_: pkgs: {
        virtualenv-hook = pkgs.runCommand "virtualenv-hook" { } ''
          mkdir -p $out/etc/profile.d
          cat > $out/etc/profile.d/virtualenv-hook.sh <<'EOF'
          #!/bin/sh
          export virtualEnv="''${virtualEnv-./nb-venv/}"
          if [ -d "$virtualEnv" ]; then
            echo; echo -n "⚡️ Activating existing venv in $virtualEnv..."
            . "$virtualEnv"/bin/activate
            echo "done."
          fi

          # If we see a requirements.txt file, install its contents
          # into a virtual environment

          if [ -f requirements.txt ]; then
            echo -n "🐍 Processing requirements.txt..."
            [ ! -d "$virtualEnv" ] && python -m venv "$virtualEnv"
            . "$virtualEnv"/bin/activate
            pip3 -qq install -r requirements.txt
            echo "done."
          fi
          EOF
          chmod +x $out/etc/profile.d/virtualenv-hook.sh
        '';
      }) nixpkgs.legacyPackages;
    };
}
