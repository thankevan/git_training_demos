# Git Training Demos

These are meant to go along with a talk and slidedeck, but you can use them on their own as well.

## Git objects demo
`git_objects_demo.sh` will walk you through how objects, hashes, and commits work at a low level using a fake prompt but executing real commands. It should be run from within an empty folder.

## Git strategies, comparing rebase to merge
`git_strategy_clean_rebases.sh` & `git_strategy_messy_merge.sh` will show the differences of how the main branch looks depending on your merge strategy. It replicates the same actions taken for a small team using each of the strategies and showing the branch graph.

## Fixing a common conflict scenario when rebasing and using feature branches
`git_feature_branching_rebase_conflict.sh` gets you into a common conflict situation when branching off of a feature branch. The resolution is to do an interactive rebase of Branch B onto main after the Feature Branch A is merged and then removing the lines belonging to branch A.

