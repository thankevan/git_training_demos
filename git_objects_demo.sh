#!/bin/bash

function _ask_for_input() {
  local text="$1"
  local default="$2"
  local input

  read -r -p "$text" input
  if [ -z "$input" ] && [ -n "$default" ]; then
    input="$default"
  fi
  echo "$input"
}

_type_text() {
  local text="$1"
  local base_delay="${2:-0.1}"  # Default delay of 0.1 seconds between characters
  local space_delay="$(echo "$base_delay * 3" | bc)"

  for (( i=0; i<${#text}; i++ )); do
    cur_delay="$base_delay"
    char="${text:$i:1}"
    echo -n "$char"

    # Double the delay if the character is a space
    if [[ "$char" == " " ]]; then
      cur_delay="$space_delay"
    fi

    sleep "$cur_delay"
  done
  echo  # New line after typing is complete
}

function _pause_in_place() {
  read -n 1 -s -r
}

function _pause() {
  read -p ""
}

_DIR=""
function _echo_fake_prompt() {
  if [ -n "$1" ]; then
    _DIR="$1"
  fi

  echo ""
  echo -n "$_DIR> "
  _pause_in_place
}

function _echo_fake_command() {
  echo -n "$1"
  _pause
}

#echo using read to create a pause and add a new line for spacing
function _echo_r() {
  echo "$1"
  _pause
}

#echo with a prompt and pause
function _echo_p() {
  read -p "> $1"
}

#echo comment
function _echo_c() {
  local reset=`echo -e '\033[00m'`
  local green=`echo -e '\033[32m'`

  echo "$green# $1$reset"
}

#echo highlight
function _echo_h() {
  local reset=`echo -e '\033[00m'`
  local yellow=`echo -e '\033[1;33m'`

  echo "$yellow$1$reset"
}

#directory="$(_ask_for_input 'please specify directory to create: ')"
directory="$1"
clear

if [ -z "$directory" ] || [ -e "$directory" ]; then
  echo "you need to specify a directory that doesn't exist"
  exit 1
fi

# INITIALIZE GIT IN DIRECTORY
_echo_fake_prompt

_echo_fake_command "mkdir $directory"
mkdir "$directory"
_echo_fake_prompt

_echo_fake_command "cd $directory"
cd "$directory"
_echo_fake_prompt $directory

_echo_fake_command "git init ."
git init .
_echo_fake_prompt

_echo_fake_command "ls .git"
ls --color=always -1 .git
_echo_fake_prompt

_echo_fake_command "find .git/objects"
find .git/objects
_echo_fake_prompt

# CREATE FILE 1 AND DISPLAY CONTENTS

_echo_fake_command "echo \"hello\" >file1.txt"
echo "hello" >file1.txt
_echo_fake_prompt

_echo_fake_command "git hash-object file1.txt"
file1_sha="$(git hash-object file1.txt)"
_echo_h $file1_sha
_echo_fake_prompt

_echo_fake_command "find .git/objects"
find .git/objects
_echo_fake_prompt

_echo_fake_command "git hash-object -w file1.txt"
file1_sha="$(git hash-object -w file1.txt)"
_echo_h $file1_sha
_echo_fake_prompt

_echo_fake_command "find .git/objects"
find .git/objects
_echo_fake_prompt

_echo_fake_command "cat .git/objects/${file1_sha:0:2}/${file1_sha:2} && echo \"\""
cat .git/objects/${file1_sha:0:2}/${file1_sha:2} && echo ""
_echo_fake_prompt

_echo_fake_command "git cat-file -t $file1_sha"
git cat-file -t "$file1_sha"
_echo_fake_prompt

_echo_fake_command "git cat-file -s $file1_sha"
git cat-file -s "$file1_sha"
_echo_fake_prompt

_echo_fake_command "git cat-file -p $file1_sha"
git cat-file -p "$file1_sha"


_pause
_echo_c "Where does that come from?"
_echo_fake_prompt

# brew install qpdf to get zlib-flate
_echo_fake_command "zlib-flate -uncompress <.git/objects/${file1_sha:0:2}/${file1_sha:2}"
zlib-flate -uncompress <.git/objects/${file1_sha:0:2}/${file1_sha:2}
_echo_fake_prompt


# CREATE FILE 2 IN SUBDIR - show the same content is the same blob

_echo_fake_command "mkdir subdir"
mkdir subdir
_echo_fake_prompt

_echo_fake_command "echo \"hello\" >subdir/file2.txt"
echo "hello" >subdir/file2.txt
_echo_fake_prompt

_echo_fake_command "chmod +x subdir/file2.txt"
chmod +x subdir/file2.txt
_echo_fake_prompt

_echo_fake_command "git hash-object -w subdir/file2.txt"
file2_sha="$(git hash-object -w subdir/file2.txt)"
_echo_h $file2_sha
_echo_fake_prompt

_echo_fake_command "find .git/objects"
find .git/objects
_echo_fake_prompt

# CREATE FILE 3

_echo_fake_command "echo \"goodbye\" >file3.txt"
echo "goodbye" >file3.txt
_echo_fake_prompt

_echo_fake_command "git hash-object -w file3.txt"
file3_sha="$(git hash-object -w file3.txt)"
_echo_h $file3_sha
_echo_fake_prompt

_echo_fake_command "find .git/objects"
find .git/objects



# STAGE FILE 1 & 2

echo "" && _pause
_echo_c "stage the first file"
# 100 is a file 644 are the permissions rw-r--r--
_echo_fake_prompt
_echo_fake_command "git update-index --add --cacheinfo 100644 $file1_sha file1.txt"
git update-index --add --cacheinfo 100644 $file1_sha file1.txt
_echo_fake_prompt

_echo_fake_command "ls .git"
ls --color=always -1 .git
_echo_fake_prompt

_echo_fake_command "git ls-files --stage"
git ls-files --stage
_echo_fake_prompt

_echo_fake_command "git update-index --add --cacheinfo 100755 $file2_sha subdir/file2.txt"
git update-index --add --cacheinfo 100755 $file2_sha subdir/file2.txt
_echo_fake_prompt

_echo_fake_command "git ls-files --stage"
git ls-files --stage
_echo_fake_prompt

_pause
_echo_c "do a git status"
_pause

#_echo_fake_command "git diff-index --cached HEAD"
#git diff-index --cached HEAD
#_echo_fake_prompt

echo ""
_echo_c "create a tree object from the staging info"
_echo_fake_prompt
_echo_fake_command "git write-tree"
tree1_sha=$(git write-tree)
_echo_h $tree1_sha
_echo_fake_prompt

# show the tree
_echo_fake_command "git cat-file -t $tree1_sha"
git cat-file -t "$tree1_sha"
_echo_fake_prompt

_echo_fake_command "git cat-file -p $tree1_sha"
git cat-file -p $tree1_sha

echo "" && _pause
_echo_c "get subtree sha"
_pause
subtree_sha="$(git cat-file -p $tree1_sha | grep tree | awk "{print \$3}")"
_echo_h "$subtree_sha"
_echo_fake_prompt
_echo_fake_command "git cat-file -p $subtree_sha"
git cat-file -p $subtree_sha
_echo_fake_prompt


# commit 1
_echo_fake_command "echo 'first commit' | git commit-tree $tree1_sha"
commit1_sha="$(echo 'first commit' | git commit-tree $tree1_sha)"
_echo_h $commit1_sha
_echo_fake_prompt

_echo_fake_command "zlib-flate -uncompress <.git/objects/${commit1_sha:0:2}/${commit1_sha:2}"
zlib-flate -uncompress <.git/objects/${commit1_sha:0:2}/${commit1_sha:2}
_echo_fake_prompt

_echo_fake_command "git update-ref refs/heads/main $commit1_sha"
git update-ref refs/heads/main $commit1_sha
_echo_fake_prompt

#git update-index --refresh
#git read-tree HEAD

_echo_fake_command "git ls-files --stage"
git ls-files --stage

_echo_c "do a git status"

#_echo_fake_command "git diff-index --cached HEAD"
#git diff-index --cached HEAD
#_echo_fake_prompt

_echo_fake_prompt
_echo_fake_command "find .git/objects -print0 | xargs -0 stat -f '%B %N' | sort -n |cut -d' ' -f2-"
find .git/objects -print0 | xargs -0 stat -f '%B %N' | sort -n |cut -d' ' -f2-
_echo_fake_prompt


# stage file 3 and commit 2

_echo_fake_command "git update-index --add --cacheinfo 100644 $file3_sha file3.txt"
git update-index --add --cacheinfo 100644 $file3_sha file3.txt
_echo_fake_prompt

_echo_fake_command "git write-tree"
tree2_sha=$(git write-tree)
_echo_h $tree2_sha
_echo_fake_prompt

_echo_fake_command "git cat-file -p $tree2_sha"
git cat-file -p "$tree2_sha"
_echo_fake_prompt

_echo_fake_command "echo 'second commit' | git commit-tree $tree2_sha -p $commit1_sha"
commit2_sha="$(echo 'second commit' | git commit-tree $tree2_sha -p $commit1_sha)"
_echo_h $commit2_sha
_echo_fake_prompt

_echo_fake_command "zlib-flate -uncompress <.git/objects/${commit2_sha:0:2}/${commit2_sha:2}"
zlib-flate -uncompress <.git/objects/${commit2_sha:0:2}/${commit2_sha:2}

echo "" && _pause
_echo_c "look at refs & logs here"

_echo_fake_prompt
_echo_fake_command "git update-ref refs/heads/main $commit2_sha"
git update-ref refs/heads/main $commit2_sha

echo "look again here"

# create a tag

_echo_fake_prompt
_echo_fake_command "git tag -a first_commit -m \"First commit\" $commit1_sha"
git tag -a first_commit -m "First commit" "$commit1_sha"
_echo_fake_prompt

_echo_fake_command "git rev-parse first_commit"
tag_sha="$(git rev-parse first_commit)"
_echo_h $tag_sha
_echo_fake_prompt

_echo_fake_command "find .git/objects -print0 | xargs -0 stat -f '%B %N' | sort -n |cut -d' ' -f2-"
find .git/objects -print0 | xargs -0 stat -f '%B %N' | sort -n |cut -d' ' -f2-
_echo_fake_prompt

