let
  key = hostname: builtins.readFile (./keys + "/${hostname}.pub");
in
{
  "anthropic-api-key.age".publicKeys = map key [
    "madoka"
    "kyubey"
  ];
  "gemini-api-key.age".publicKeys = map key [
    "madoka"
    "kyubey"
  ];
  "gemini-project-id.age".publicKeys = map key [
    "madoka"
    "kyubey"
  ];
  "jira-api-key.age".publicKeys = map key [
    "madoka"
    "kyubey"
  ];
  "mount-kyubey-dav-bat.age".publicKeys = map key [
    "madoka"
    "kyubey"
  ];
  "copyparty-vereis-password.age".publicKeys = map key [ "kyubey" ];
  "copyparty-turtz-password.age".publicKeys = map key [ "kyubey" ];
  "cloudflare-ddclient-token.age".publicKeys = map key [ "kyubey" ];
  "minecraft-rcon-password.age".publicKeys = map key [ "kyubey" ];
}
