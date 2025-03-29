#!/bin/bash

c_reset=`echo -e '\033[00m'`
c_yellow=`echo -e '\033[1;33m'`
c_green=`echo -e '\033[32m'`


dirname="clean_rebases"
filenumber="0"
simple="$1"

function _simple_check() {
  if [ "$simple" = "-s" ]; then
    return 0
  else
    return 1
  fi
}

function _simple_mode_branch_changes() {
  if ! _simple_check; then
    echo $1
    return
  fi

  if [ "$1" = "dev" ]; then
    echo "main"
  else
    echo "$1"
  fi
}

# use like _simple_mode_skip_hotfixes_check <branch> || return
function _simple_mode_skip_hotfixes_check() {
  if ! _simple_check; then
    return 0
  fi

  if [ "$1" = "Hotfix_1" ] || [ "$1" = "Hotfix_2" ]; then
    return 1
  fi

  return 0
}

# use like _simple_mode_skip_dev_check <branch> || return
function _simple_mode_skip_dev_check() {
  if ! _simple_check; then
    return 0
  fi

  if [ "$1" = "dev" ]; then
    return 1
  fi

  return 0
}

# use like _simple_mode_skip_matching_branches_check <branch> <branch> || return
function _simple_mode_skip_matching_branches_check() {
  if ! _simple_check; then
    return 0
  fi

  if [ "$1" = "$2" ]; then
    return 1
  fi

  return 0
}

function _checkout_branch() {
  _simple_mode_skip_hotfixes_check $1 || return
  local branch="$(_simple_mode_branch_changes $1)"

  if [ "$(git branch --show-current)" = "$branch" ]; then
    return 0
  fi
  echo "${c_yellow}Switch to $branch${c_reset}"
  git switch "$branch"
}

function _create_branch() {
  _simple_mode_skip_hotfixes_check $1 || return
  _simple_mode_skip_dev_check $1 || return
  local branch="$(_simple_mode_branch_changes $1)"

  echo "${c_yellow}Create branch $branch${c_reset}"
  git branch "$branch"
  sleep 1
}

function _create_branch_and_switch() {
  _create_branch "$1"
  _checkout_branch "$1"
}

function _create_branch_from_branch() {
  _simple_mode_skip_hotfixes_check $1 || return
  _simple_mode_skip_hotfixes_check $2 || return
  local create_branch="$(_simple_mode_branch_changes $1)"
  local from_branch="$(_simple_mode_branch_changes $2)"
  _simple_mode_skip_matching_branches_check $create_branch $from_branch || return

  _checkout_branch "$from_branch"
  _create_branch "$create_branch"
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
  _simple_mode_skip_hotfixes_check $1 || return
  local branch="$(_simple_mode_branch_changes $1)"
  _checkout_branch $branch
  _make_file_and_commit
}

function _merge_branch_into_branch() {
  _simple_mode_skip_hotfixes_check $1 || return
  _simple_mode_skip_hotfixes_check $2 || return
  local branch="$(_simple_mode_branch_changes $1)"
  local into_branch="$(_simple_mode_branch_changes $2)"
  _simple_mode_skip_matching_branches_check $branch $into_branch || return

  local message="Merge: $branch -> $into_branch"
  _checkout_branch "$into_branch"
  echo "${c_yellow}$message${c_reset}"
  git merge --no-ff "$branch" -m "$message"
  sleep 1
}

function _rebase_branch_onto_branch() {
  _simple_mode_skip_hotfixes_check $1 || return
  _simple_mode_skip_hotfixes_check $2 || return
  local branch="$(_simple_mode_branch_changes $1)"
  local onto_branch="$(_simple_mode_branch_changes $2)"
  _simple_mode_skip_matching_branches_check $branch $onto_branch || return

  _checkout_branch "$branch"
  echo "${c_yellow}Rebase: $branch onto $onto_branch${c_reset}"
  git rebase "$onto_branch"
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

