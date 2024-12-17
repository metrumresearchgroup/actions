#!/bin/sh

# Copyright 2024 Metrum Research Group
# SPDX-License-Identifier: MIT
# Author: Kyle Meyer

set -eu

usage () {
    cat <<EOF
Usage: $0 [--sync=REMOTE] [--target-branch=BRANCH] [--] SUBDIR

Create a commit on the gh-pages branch with the contents of SUBDIR.
The contents of SUBDIR do not need to be tracked in the current branch
(and in most cases should not be).

Options:
  --sync=REMOTE
    Sync with REMOTE by 1) fetching and then resetting the gh-pages
    branch to REMOTE/gh-pages before making the new commit for SUBDIR
    and 2) pushing to REMOTE after making the new commit.
  --target-branch=BRANCH
    Commit to BRANCH instead of "gh-pages".  Be careful with this
    option if you're using --sync because in that case BRANCH will be
    published to REMOTE.
EOF
    exit 1
}

remote=
branch=gh-pages

while test $# -gt 0
do
    case "$1" in
        --sync)
            test -n "${2-}" || usage
            remote=$2
            shift
            ;;
        --sync=*)
            remote=${1#--sync=}
            ;;
        --target-branch)
            test -n "${2-}" || usage
            branch=$2
            shift
            ;;
        --target-branch=*)
            branch=${1#--target-branch=}
            ;;
        --)
            shift
            break
            ;;
        -*)
            usage
            ;;
        *)
            break
    esac
    shift
done
test $# -eq 1 || usage

sdir=$1
ref=refs/heads/$branch

test -d "$sdir" || {
    printf >&2 'Directory does not exist: %s\n' "$sdir"
    exit 1
}

test -z "$(find "$sdir" -maxdepth 0 -type d -empty)" || {
    printf >&2 'Directory is empty: %s\n' "$sdir"
    exit 1
}

git rev-parse --verify -q HEAD >/dev/null || {
    printf >&2 'No commits yet on this branch\n'
    exit 1
}

sdir_top=$(cd "$sdir" && git rev-parse --show-prefix)

head=$(git describe --always HEAD)
git_dir=$(git rev-parse --git-dir)
GIT_INDEX_FILE=$(mktemp "$git_dir"/index.tmp.XXXXXXX)
export GIT_INDEX_FILE
trap 'rm -f "$GIT_INDEX_FILE"' 0

git read-tree --empty
git add --force -- "$sdir"
tree=$(git write-tree)
tree_noprefix=$(git rev-parse "$tree:$sdir_top")

fetched=
if test -n "$remote"
then
    remote_ref=refs/remotes/$remote/$branch
    if git fetch "$remote" "$branch"
    then
        fetched=1
        oldval=$(git rev-parse -q --verify "$ref^{commit}") || :
        git update-ref -m reset "$ref" "$remote_ref" "$oldval"
    elif git rev-parse -q --verify "$remote_ref^{commit}"
    then
         printf >&2 \
                'Remote-tracking branch does not exist on remote: %s\n' \
                "$branch"
         printf >&2 'Try calling "git fetch --prune %s" first\n' "$remote"
         exit 1
    fi
fi

make_commit=1
parent=$(git rev-parse -q --verify "$ref^{commit}") || :
if test -z "$parent"
then
    tree_empty=$(git hash-object -t tree /dev/null)
    commit0=$(git commit-tree -m 'initial commit' "$tree_empty")
    git update-ref -m initial "$ref" "$commit0" ''
    parent=$commit0
elif git diff-tree --quiet "$tree_noprefix" "$ref"
then
    printf 'No changes between %s and %s\n' "$sdir" "$branch"
    if test -z "$remote"
    then
        exit 0
    elif test -n "$fetched" &&
            git diff-tree --quiet "$tree_noprefix" "refs/remotes/$remote/$branch"
    then
        printf 'No changes between local and remote %s\n' "$branch"
        exit 0
    else
        make_commit=
    fi
fi

if test -n "$make_commit"
then
    msg="regenerate from $head:$sdir_top"
    commit=$(git commit-tree -m "$msg" -p "$parent" "$tree_noprefix")
    git update-ref -m regenerate "$ref" "$commit" "$parent"
fi

test -z "$remote" || git push "$remote" "$ref:$ref"
