#!/bin/bash

c_reset=`echo -e '\033[00m'`
c_yellow=`echo -e '\033[1;33m'`
c_green=`echo -e '\033[32m'`


dirname="clean_rebases"
filenumber="0"

function _fail_out() {
  echo "ERROR"
  exit 1
}

function _checkout_branch() {
  if [ "$(git branch --show-current)" = "$1" ]; then
    return 0
  fi
  echo "${c_yellow}Switch to $1${c_reset}"
  git switch "$1"
}

function _create_branch() {
  echo "${c_yellow}Create branch $1${c_reset}"
  git branch "$1"
  sleep 1
}

function _create_branch_and_switch() {
  _create_branch "$1"
  _checkout_branch "$1"
}

function _create_branch_from_branch() {
  _checkout_branch "$2"
  _create_branch "$1"
}

function _create_branch_from_branch_and_switch() {
  _create_branch_from_branch "$1" "$2"
  _checkout_branch "$1"
}

function _make_file_and_commit() {
  (( filenumber += 1 ))
  local curbranch="$(git branch --show-current)"
  local filename="File_${filenumber}_${curbranch}.txt"
  local message="$curbranch: $filename"
  echo "${c_yellow}Create & commit file $filename${c_reset}"


  echo "$filename" >$filename
  git add $filename
  git commit -m "$message"
  sleep 1
}

function _make_file_and_commit_from_branch() {
  _checkout_branch $1
  _make_file_and_commit
}

function _merge_branch_into_branch() {
  local message="Merge: $1 -> $2"
  _checkout_branch "$2"
  echo "${c_yellow}$message${c_reset}"
  git merge --no-ff "$1" -m "$message"
  sleep 1
}

function _rebase_branch_onto_branch() {
  _checkout_branch "$1"
  echo "${c_yellow}Rebase: $1 onto $2${c_reset}"
  git rebase "$2"
  sleep 1
}

# Initialize a new Git repository
mkdir "$dirname"
cd "$dirname"
git init


_make_file_and_commit_from_branch main
_create_branch_and_switch dev
_create_branch_from_branch Feature_1 dev
_create_branch_from_branch Feature_2 dev
_make_file_and_commit_from_branch Feature_1
_make_file_and_commit_from_branch Feature_2
_make_file_and_commit_from_branch Feature_1
_make_file_and_commit_from_branch Feature_2
_make_file_and_commit_from_branch Feature_1
_create_branch_from_branch Feature_3 Feature_2
_make_file_and_commit_from_branch Feature_3
_rebase_branch_onto_branch Feature_1 dev
_merge_branch_into_branch Feature_1 dev
_create_branch_from_branch Feature_4 dev
_make_file_and_commit_from_branch Feature_2
_rebase_branch_onto_branch Feature_2 dev
_merge_branch_into_branch Feature_2 dev
_create_branch_from_branch Feature_5 dev
_merge_branch_into_branch dev main
_rebase_branch_onto_branch Feature_3 Feature_2
_make_file_and_commit_from_branch Feature_3
_make_file_and_commit_from_branch Feature_5
_make_file_and_commit_from_branch Feature_4
_make_file_and_commit_from_branch Feature_3
_make_file_and_commit_from_branch Feature_4
_create_branch_from_branch Hotfix_1 main
_make_file_and_commit_from_branch Hotfix_1
_rebase_branch_onto_branch Hotfix_1 main
_merge_branch_into_branch Hotfix_1 main
_merge_branch_into_branch main dev
_make_file_and_commit_from_branch Feature_5
_make_file_and_commit_from_branch Feature_4
_create_branch_from_branch Feature_6 dev
_rebase_branch_onto_branch Feature_3 dev
_merge_branch_into_branch Feature_3 dev
_make_file_and_commit_from_branch Feature_6
_merge_branch_into_branch dev main
_make_file_and_commit_from_branch Feature_4
_make_file_and_commit_from_branch Feature_5
_create_branch_from_branch Hotfix_2 main
_make_file_and_commit_from_branch Hotfix_2
_rebase_branch_onto_branch Feature_5 dev
_merge_branch_into_branch Feature_5 dev
_make_file_and_commit_from_branch Feature_6
_make_file_and_commit_from_branch Feature_6
_make_file_and_commit_from_branch Feature_4
_rebase_branch_onto_branch Feature_4 dev
_merge_branch_into_branch Feature_4 dev
_make_file_and_commit_from_branch Hotfix_2
_rebase_branch_onto_branch Hotfix_2 main
_merge_branch_into_branch Hotfix_2 main
_create_branch_from_branch Subfeature_6_1 Feature_6
_merge_branch_into_branch main dev
_make_file_and_commit_from_branch Subfeature_6_1
_make_file_and_commit_from_branch Feature_6
_make_file_and_commit_from_branch Feature_6
_make_file_and_commit_from_branch Subfeature_6_1
_rebase_branch_onto_branch Subfeature_6_1 Feature_6
_merge_branch_into_branch Subfeature_6_1 Feature_6
_rebase_branch_onto_branch Feature_6 dev
_merge_branch_into_branch Feature_6 dev
_merge_branch_into_branch dev main
echo "${c_yellow}DONE${c_reset}"
echo ""
echo ""
echo ""

# TIME ORDERED
GIT_PAGER=cat git log --graph --abbrev-commit --date-order --decorate --format=format:'%C(bold cyan)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(bold white)%s%C(reset) - %C(yellow)%an%C(reset)%C(auto)%d%C(reset)' && echo ""

echo ""
echo ""
echo ""
echo ""
echo ""
echo ""
echo ""

# GIT ORDER (lump commits by branch)
GIT_PAGER=cat git log --graph --abbrev-commit --decorate --format=format:'%C(bold cyan)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(bold white)%s%C(reset) - %C(yellow)%an%C(reset)%C(auto)%d%C(reset)' && echo ""

cd ..
rm -rf "$dirname"

