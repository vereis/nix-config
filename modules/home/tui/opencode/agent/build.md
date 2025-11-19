---
mode: primary
permission:
  external_directory: allow
  edit: ask
  bash:
    ls*: allow
    cat*: allow
    grep*: allow
    rg*: allow
    find*: allow
    head*: allow
    tail*: allow
    tree*: allow
    git add*: ask
    git commit*: ask
    git push*: ask
    git pull: allow
    git fetch: allow
    git checkout*: allow
    git switch*: allow
    git branch: allow
    git branch -d*: ask
    git branch -D*: ask
    git status: allow
    git diff*: allow
    git log*: allow
    git show*: allow
    git grep*: allow
    git reset --hard*: ask
    git reset --soft*: ask
    git reset --mixed*: ask
    git clean*: ask
    git rebase*: ask
    git merge*: ask
    git cherry-pick*: ask
    git revert*: ask
    git tag: allow
    git tag -d*: ask
    git rev-parse*: allow
    git remote*: allow
    git stash: allow
    git stash pop*: ask
    git stash apply*: ask
    git stash drop*: ask
    git mv*: ask
    git rm*: ask
    git restore*: allow
    git submodule*: allow
    jira issue list*: allow
    jira issue view*: allow
    jira sprint list*: allow
    jira board*: allow
    jira epic list*: allow
    jira epic view*: allow
    jira project*: allow
    jira me: allow
    jira serverinfo: allow
    jira issue create*: ask
    jira issue edit*: ask
    jira issue delete*: ask
    jira issue assign*: ask
    jira issue move*: ask
    jira issue clone*: ask
    jira issue link*: ask
    jira issue unlink*: ask
    jira issue watch*: ask
    jira issue comment*: ask
    jira issue worklog*: ask
    jira epic create*: ask
    jira epic add*: ask
    jira epic remove*: ask
    gh issue list*: allow
    gh issue view*: allow
    gh issue status: allow
    gh pr list*: allow
    gh pr view*: allow
    gh pr status: allow
    gh pr checks*: allow
    gh pr diff*: allow
    gh repo view*: allow
    gh repo list*: allow
    gh search*: allow
    gh browse: allow
    gh issue create*: ask
    gh issue edit*: ask
    gh issue close*: ask
    gh issue delete*: ask
    gh issue comment*: ask
    gh issue lock*: ask
    gh issue unlock*: ask
    gh issue pin*: ask
    gh issue unpin*: ask
    gh issue reopen*: ask
    gh issue transfer*: ask
    gh pr create*: ask
    gh pr edit*: ask
    gh pr close*: ask
    gh pr merge*: ask
    gh pr reopen*: ask
    gh pr ready*: ask
    gh pr review*: ask
    gh pr comment*: ask
    gh pr lock*: ask
    gh pr unlock*: ask
    gh pr checkout*: allow
---
