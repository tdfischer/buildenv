git status
for remote in $(git remote show);do
  git remote show -n $remote
done
