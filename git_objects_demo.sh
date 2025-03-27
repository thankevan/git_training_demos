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

function _pause() {
  read -p ""
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

#echo comment
function _echo_h() {
  local reset=`echo -e '\033[00m'`
  local yellow=`echo -e '\033[1;33m'`

  echo "$yellow$1$reset"
  _pause
}

#directory="$(_ask_for_input 'please specify directory to create: ')"
directory="$1"
clear

if [ -z "$directory" ] || [ -e "$directory" ]; then
  echo "you need to specify a directory that doesn't exist"
  exit 1
fi

# INITIALIZE GIT IN DIRECTORY
_echo_p "mkdir $directory"
mkdir "$directory"

_echo_p "cd $directory"
cd "$directory"

_echo_p "git init ."
git init .
_pause

_echo_p "ls .git"
ls --color=always -1 .git
_pause

_echo_p "find .git/objects"
find .git/objects
_pause

# CREATE FILE 1 AND DISPLAY CONTENTS

_echo_p "echo \"hello\" >file1.txt"
echo "hello" >file1.txt

_echo_p "git hash-object file1.txt"
file1_sha="$(git hash-object file1.txt)"
_echo_h $file1_sha

_echo_p "find .git/objects"
find .git/objects
_pause

_echo_p "git hash-object -w file1.txt"
file1_sha="$(git hash-object -w file1.txt)"
_echo_h $file1_sha

_echo_p "find .git/objects"
find .git/objects
_pause

#_echo_p "ls .git/objects/${file1_sha:0:2}"
#ls .git/objects/${file1_sha:0:2}

_echo_p "cat .git/objects/${file1_sha:0:2}/${file1_sha:2} && echo \"\""
cat .git/objects/${file1_sha:0:2}/${file1_sha:2} && echo ""
_pause

_echo_p "git cat-file -t $file1_sha"
git cat-file -t "$file1_sha"
_pause

_echo_p "git cat-file -s $file1_sha"
git cat-file -s "$file1_sha"
_pause

_echo_p "git cat-file -p $file1_sha"
git cat-file -p "$file1_sha"
_pause

# brew install qpdf to get zlib-flate
_echo_p "zlib-flate -uncompress <.git/objects/${file1_sha:0:2}/${file1_sha:2}"
zlib-flate -uncompress <.git/objects/${file1_sha:0:2}/${file1_sha:2}
_pause


# CREATE FILE 2 IN SUBDIR - show the same content is the same blob

_echo_p "mkdir subdir"
mkdir subdir

_echo_p "echo \"hello\" >subdir/file2.txt"
echo "hello" >subdir/file2.txt

_echo_p "git hash-object -w subdir/file2.txt"
file2_sha="$(git hash-object -w subdir/file2.txt)"
_echo_h $file2_sha

_echo_p "find .git/objects"
find .git/objects
_pause

# CREATE FILE 3

_echo_p "echo \"goodbye\" >file3.txt"
echo "goodbye" >file3.txt

_echo_p "git hash-object -w file3.txt"
file3_sha="$(git hash-object -w file3.txt)"
_echo_h $file3_sha



# STAGE FILE 1 & 2

_echo_c "stage the first file"
# 100 is a file 644 are the permissions rw-r--r--
_echo_p "git update-index --add --cacheinfo 100644 $file1_sha file1.txt"
git update-index --add --cacheinfo 100644 $file1_sha file1.txt
#_pause

_echo_p "ls .git"
ls --color=always -1 .git
_pause

_echo_p "git ls-files --stage"
git ls-files --stage
_pause

_echo_p "git update-index --add --cacheinfo 100644 $file2_sha subdir/file2.txt"
git update-index --add --cacheinfo 100644 $file2_sha subdir/file2.txt
#_pause

_echo_p "git ls-files --stage"
git ls-files --stage
_pause

#_echo_p "git diff-index --cached HEAD"
#git diff-index --cached HEAD
#_pause

_echo_c "create a tree object from the staging info"
_echo_p "git write-tree"
tree1_sha=$(git write-tree)
_echo_h $tree1_sha

# show the tree
_echo_p "git cat-file -t $tree1_sha"
git cat-file -t "$tree1_sha"
_pause

_echo_p "git cat-file -p $tree1_sha"
git cat-file -p $tree1_sha
_pause

subtree_sha="$(git cat-file -p $tree1_sha | grep tree | awk "{print \$3}")"
_echo_p "git cat-file -p $subtree_sha"
git cat-file -p $subtree_sha
_pause


# commit 1
_echo_p "echo 'first commit' | git commit-tree $tree1_sha"
commit1_sha="$(echo 'first commit' | git commit-tree $tree1_sha)"
_echo_h $commit1_sha

_echo_p "git update-ref refs/heads/main $commit1_sha"
git update-ref refs/heads/main $commit1_sha
_pause

#git update-index --refresh
#git read-tree HEAD

_echo_p "git ls-files --stage"
git ls-files --stage
_pause

_echo_p "git diff-index --cached HEAD"
git diff-index --cached HEAD
_pause

_echo_p "find .git/objects -print0 | xargs -0 stat -f '%B %N' | sort -n |cut -d' ' -f2-"
find .git/objects -print0 | xargs -0 stat -f '%B %N' | sort -n |cut -d' ' -f2-
_pause


# stage file 3 and commit 2

_echo_p "git update-index --add --cacheinfo 100644 $file3_sha file3.txt"
git update-index --add --cacheinfo 100644 $file3_sha file3.txt
#_pause

_echo_p "git write-tree"
tree2_sha=$(git write-tree)
_echo_h $tree2_sha

_echo_p "git cat-file -p $tree2_sha"
git cat-file -p "$tree2_sha"
_pause

_echo_p "echo 'second commit' | git commit-tree $tree2_sha -p $commit1_sha"
commit2_sha="$(echo 'second commit' | git commit-tree $tree2_sha -p $commit1_sha)"
_echo_h $commit2_sha

echo "look at diff here"

_echo_p "git update-ref refs/heads/main $commit2_sha"
git update-ref refs/heads/main $commit2_sha
_pause

echo "look again here"
