To set up new secrets:

1. Create an empty file and add it to the repo via `git add $FILE -f`
2. Ensure that you don't track future changes to the file via `git update-index --assume-unchanged $FILE`
3. Read the file in other Nix modules via `builtins.readFile $FILE`
