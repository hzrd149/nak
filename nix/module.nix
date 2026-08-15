self:
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.nak;
in
{
  options.programs.nak = {
    enable = lib.mkEnableOption "nak, the nostr army knife";

    package = lib.mkOption {
      type = lib.types.package;
      default = self.packages.${pkgs.stdenv.hostPlatform.system}.default;
      defaultText = lib.literalExpression "inputs.nak.packages.${pkgs.stdenv.hostPlatform.system}.default";
      description = "The nak package to install.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];
  };
}
