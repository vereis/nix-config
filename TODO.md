# NixOS Configuration TODO

## Media Server Permissions Issue

### Problem

The `systemd.tmpfiles.rules` in `media-server.nix` uses different permissions than `copyparty.nix`:

**Current media-server.nix:**

```nix
"d ${config.modules.media-server.mediaPath} 0755 root media - -"
"Z ${config.modules.media-server.mediaPath} 0755 root media - -"
```

**copyparty.nix (better approach):**

```nix
"Z ${path} 2775 root media - -"
```

### Key Differences

1. **Permissions:**

   - `0755`: Group `media` has `r-x` (read/execute only, NO write)
   - `2775`: Group `media` has `rwx` (read/write/execute)

1. **setgid Bit (the `2` prefix in `2775`):**

   - When set on a directory, all new files/subdirectories inherit the directory's group (`media`)
   - Without setgid: New files get the creating user's primary group
   - With setgid: New files always get the `media` group automatically

1. **Type Codes:**

   - `d`: Creates directory if missing, doesn't change existing file permissions
   - `Z`: Recursively changes permissions/ownership of ALL files/subdirectories

### Issues with Current Setup

1. Plex/Jellyfin can only READ, not WRITE to media directories
1. If services need to write metadata, thumbnails, or subtitle files, they can't
1. Inconsistent with copyparty configuration
1. Files uploaded via copyparty might not be accessible properly

### Recommended Fix

**Option 1: Match copyparty (Read/Write + setgid) - RECOMMENDED**

```nix
systemd.tmpfiles.rules = [
  "d ${config.modules.media-server.mediaPath} 2775 root media - -"
  "Z ${config.modules.media-server.mediaPath} 2775 root media - -"
];
```

Benefits:

- Consistent with copyparty
- Future-proof for metadata/artwork writing
- setgid ensures proper group ownership
- Media group can write

**Option 2: Keep read-only but simplify**

```nix
systemd.tmpfiles.rules = [
  "Z ${config.modules.media-server.mediaPath} 0755 root media - -"
];
```

Benefits:

- Simpler (one line, directory already exists)
- Truly read-only media

### Action Required

Decide which approach to use and update `modules/services/media-server.nix` accordingly.
