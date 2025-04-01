#!/bin/bash

dirname="squash_rebase_conflict"

function _echo_yellow() {
  local c_reset=`echo -e '\033[00m'`
  local c_yellow=`echo -e '\033[1;33m'`
  
  echo "${c_yellow}$1${c_reset}"
}

# Initialize a new Git repository
_echo_yellow "Initialize repo"
mkdir "$dirname"
cd "$dirname" 
git init


# Initial commit on main
_echo_yellow "Make initial commit on main, main.txt"
echo "Initial commit on main" > main.txt
git add main.txt
git commit -m "Initial commit on main"

# Create Feature_A
_echo_yellow "Create branch Feature_A off of main, and check it out"
git checkout -b Feature_A

# Make commits
_echo_yellow "Make commits to Feature_A, file_a.txt"
echo "Feature A: Commit 1" > file_a.txt
git add file_a.txt
git commit -m "Feature A: Commit 1"
echo "Feature A: Commit 2" >> file_a.txt
git add file_a.txt
git commit -m "Feature A: Commit 2"

# Create Feature_B off of Feature_A
_echo_yellow "Create branch Feature_B off of Feature_A, and check it out"
git checkout -b Feature_B

# Make commits
_echo_yellow "Make commits to Feature_B, file_b.txt"
echo "Feature B: Commit 1" > file_b.txt
git add file_b.txt
git commit -m "Feature B: Commit 1"
echo "Feature B: Commit 2" >> file_b.txt
git add file_b.txt
git commit -m "Feature B: Commit 2"

# Squash merge Feature_A into main
_echo_yellow "Checkout main"
git checkout main
_echo_yellow "Squash merge and commit Feature_A into main"
git merge --squash Feature_A
git commit -m "Squashed merge of Feature_A"

# Try to rebase Feature_B onto main
_echo_yellow "Checkout Feature_B"
git checkout Feature_B

_echo_yellow "Rebase Feature_B onto main"
git rebase main


