rm -rf SUMMARY.md
book sm
rm -rf docs/
gitbook build ./ ./docs

git add --all
git commit -m "update"
git push origin master


