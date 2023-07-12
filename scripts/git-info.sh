#!/bin/bash

BRANCH=$(git rev-parse --abbrev-ref HEAD || echo)
COMMIT=$(git rev-parse HEAD || echo)
COMMIT_SHORT=$(git rev-parse --short HEAD || echo)
ORIGIN=$(git config --get remote.origin.url || echo)

jq -n --arg branch "$BRANCH" --arg commit "$COMMIT" --arg commit_short "$COMMIT_SHORT" --arg origin "$ORIGIN" '{"branch":$branch,"commit":$commit,"origin":$origin, "commit_short":$commit_short}'
