{ ... }:
{

  services.ollama.enable = true;

  services.nextjs-ollama-llm-ui = {
    enable = true;
    port = 7001;
  };
}
