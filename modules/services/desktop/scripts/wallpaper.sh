#!/usr/bin/env bash

# Start swww daemon and load regular wallpaper for workspaces
@swww@ &
sleep 0.5

for f in "$HOME"/.wallpaper.*; do
  [ -e "$f" ] && @swww@ img "$f" --resize crop && break
done

# Start swaybg with blurred wallpaper for overview backdrop
for f in "$HOME"/.wallpaper-blur.* "$HOME"/.wallpaper.*; do
  [ -e "$f" ] && exec @swaybg@ -i "$f" -m fill
done
