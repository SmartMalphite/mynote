rm -rf docs/
book sm
gitbook build ./ ./docs

git add --all
git commit -m "update"
git push origin master


