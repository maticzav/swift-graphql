#!/bin/bash

cd scripts
pnpm ts-node index.ts

CHANGED=$(git diff-index --name-only HEAD --)

if [ ! -z "$CHANGED" ]; then

git commit -am "chore: generate TOC"
git push

fi


