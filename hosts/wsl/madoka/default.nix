{
  pkgs,
  lib,
  username,
  config,
  ...
}:

{
  imports = [ ./services.nix ];

  age = {
    secrets = builtins.listToAttrs (
      builtins.map
        (secretName: {
          name = secretName;
          value = {
            file = ../../../secrets + "/${secretName}";
          };
        })
        [
          "anthropic-api-key.age"
          "gemini-api-key.age"
          "gemini-project-id.age"
          "jira-api-key.age"
          "mount-kyubey-dav-bat.age"
        ]
    );
    identityPaths = [
      "/home/${username}/.ssh/id_ed25519"
    ];
  };

  system.stateVersion = lib.mkForce "24.05";
}
