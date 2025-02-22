{
  inputs,
  ...
}:
{
  imports = [
    inputs.emanote.homeManagerModule
  ];
  services.emanote = {
    enable = true;
    host = "127.0.0.1";
    port = 7000;
    notes = [
      "/home/fhauser/cloud/Notes"
    ];
  };
}
