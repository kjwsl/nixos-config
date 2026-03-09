# Gemini CLI
# Contributes to flake.modules.homeManager.base.
{ ... }: {
  flake.modules.homeManager.base = { ... }: {
    programs.gemini-cli = {
      enable = true;
      settings = {
        general = {
          sessionRetention = { enabled = true; maxAge = "30d"; warningAcknowledged = true; };
          enableNotifications = true;
          plan = { directory = "undefined"; modelRouting = true; };
        };
        
        mcpServers = {
          sequential-thinking = { command = "bunx"; args = [ "@modelcontextprotocol/server-sequential-thinking" ]; };
          context7 = { command = "bunx"; args = [ "@upstash/context7-mcp@latest" ]; };
          serena = { command = "uvx"; args = [ "--from" "git+https://github.com/oraios/serena" "serena" "start-mcp-server" ]; };
          # morphllm-fast-apply = { command = "bunx"; args = [ "@morph-llm/morph-fast-apply" "/home/" ]; env = { MORPH_API_KEY = ""; ALL_TOOLS = "true"; }; };
          playwright = { command = "bunx"; args = [ "@playwright/mcp@latest" ]; };
          superagent = { command = "bunx"; args = [ "@superclaude-org/superagent" ]; };
        };
        
        _disabledMcpServers = {
          magic = {
            type = "stdio"; command = "bunx"; args = [ "@21st-dev/magic" ];
            env = { TWENTYFIRST_API_KEY = ""; };
            _geminiCompatibility = "NOT_COMPATIBLE - Tool names start with '21st_' which violates Gemini function naming rules";
            _disabledReason = "Tool names start with '21st_' which violates Gemini's function naming rules (must start with letter/underscore, not number)";
          };
        };
        
        ui = {
          showStatusInTitle = false;
          footer = { hideContextPercentage = false; };
          showMemoryUsage = true; showCitations = true;
          showModelInfoInChat = true; hideWindowTitle = true;
          inlineThinkingMode = "full"; errorVerbosity = "full";
          loadingPhrases = "tips";
        };
        tools = { shell = { showColor = true; }; };
        experimental = { modelSteering = true; plan = true; directWebFetch = true; };
      };
    };
  };
}
