{ lib, ... }:
{
  options.dotfiles.cloudRoot = lib.mkOption {
    type = lib.types.str;
    default = "~/shares/cloud.qo.is";
    description = "Path where cloud.qo.is is synced/mounted";
  };
  options.dotfiles.privatePath = lib.mkOption {
    type = lib.types.str;
    default = "~/private";
    description = "Path to private projects directory";
  };
}
