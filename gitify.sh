#!/bin/bash

git init
find * -size +4M -type f -print >> .gitignore
git add -A
git commit -m "first commit"
git branch -M main
git remote add origin https://raychorn:844b95d274cfa667c9fcbf9f70d29a917f3adcbc@github.com/raychorn/svn_ruby_projects.git
git push -u origin main
