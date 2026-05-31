{
  ...
}:
{

  programs.gh = {
    enable = true;
    gitCredentialHelper.enable = true;
    settings = {
      git_protocol = "https";
      aliases = {
        l = "pr list";
        pc = "pr checkout";
        pv = "pr view";
        r-approve = "pr review --approve";

        c = "pr create";
        r-request = "pr comment --body '/request-review'";
      };
    };
  };
}
