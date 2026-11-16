{
  description = "Example NixOS deployment via NixOS-anywhere";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs: {
    nixosConfigurations.example = inputs.nixpkgs.lib.nixosSystem {
      modules = [
        (
          { modulesPath, ... }:
          {
            imports = [
              (modulesPath + "/profiles/qemu-guest.nix")
              inputs.disko.nixosModules.disko
            ];

            nixpkgs.hostPlatform = "x86_64-linux";
            boot.loader.systemd-boot.enable = true;

            services.openssh.enable = true;
            users.users.root.openssh.authorizedKeys.keys = [
              "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJZZ7RdteXnDrMGdJNahy0aSt4PHXXtM4e0B1kmCpmP+ tfc@training-machine"
            ];

            disko.devices = {
              disk = {
                main = {
                  device = "/dev/sda";
                  type = "disk";
                  content = {
                    type = "gpt";
                    partitions = {
                      ESP = {
                        type = "EF00";
                        size = "500M";
                        content = {
                          type = "filesystem";
                          format = "vfat";
                          mountpoint = "/boot";
                          mountOptions = [ "umask=0077" ];
                        };
                      };
                      root = {
                        size = "100%";
                        content = {
                          type = "filesystem";
                          format = "ext4";
                          mountpoint = "/";
                        };
                      };
                    };
                  };
                };
              };
            };
          }
        )
      ];
    };
  };
}
