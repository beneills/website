#!/bin/bash

set -eu

CLONE_DIRECTORY="$(mktemp -d)"
REPOSITORY_DIRECTORY="$(dirname $0)/.."
SITE_DIRECTORY="$REPOSITORY_DIRECTORY/_site"
INDEX_FILE="index.html"
BRANCH_DEPLOY="gh-pages"
GITHUB_REMOTE="origin"

pushd "$REPOSITORY_DIRECTORY"
CURRENT_BRANCH="$(git rev-parse --abbrev-ref HEAD)"
if [ "$CURRENT_BRANCH" = "$BRANCH_DEPLOY" ]; then
  echo "Error: on deployment branch $BRANCH_DEPLOY" >> /dev/stderr
  exit 1
fi

if ! [ -z "$(git status --porcelain)" ]; then
  echo "Error: git repository has uncommitted changes" >> /dev/stderr
  exit 1
fi

if ! [ -z "$(git cherry -v)" ]; then
  echo "Error: git repository has commit not present remotely" >> /dev/stderr
  exit 1
fi

echo "> Generating $SITE_DIRECTORY"
jekyll build
popd

echo "> Cloning repository to $CLONE_DIRECTORY"
git clone "$REPOSITORY_DIRECTORY" "$CLONE_DIRECTORY"

echo "> Checking out $BRANCH_DEPLOY in clone directory"
pushd "$CLONE_DIRECTORY"
git checkout "$BRANCH_DEPLOY"

if ! [ -f "$INDEX_FILE" ]; then
  echo "Error: could not find index file $INDEX_FILE in branch $BRANCH_DEPLOY" >> /dev/stderr
  exit 1
fi

echo "> Clearing all non-hidden files"
rm -r *
popd

echo "> Copying all non-hidden site files to clone directory"
cp -r "$SITE_DIRECTORY"/* "$CLONE_DIRECTORY"

echo "> Committing deployment change"
pushd "$CLONE_DIRECTORY"
git add .
COMMIT_MESSAGE="Deployment from branch $CURRENT_BRANCH on `date`"
git commit --message="$COMMIT_MESSAGE"

echo "> Pushing changes back to main repository"
git push
popd

echo "> Pushing changes to Github"
pushd "$REPOSITORY_DIRECTORY"
git push "$GITHUB_REMOTE" "$BRANCH_DEPLOY"
popd

echo "> Removing clone directory"
rm -rf "$CLONE_DIRECTORY"

echo "> Done"
