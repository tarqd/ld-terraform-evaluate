#!/bin/bash

# be paranoid and exit on any error
set -e

FLAG_FILE=$(mktemp)
INPUT="$(cat)"

CLIENT_SIDE_ID=$(jq -r '.client_side_id' <<< "$INPUT")
CONTEXT=$(jq -r '.context' <<< "$INPUT")
EVALUATE_URL="https://clientsdk.launchdarkly.com/sdk/evalx/$CLIENT_SIDE_ID/context"

RESULTS="$(curl -s -X REPORT -H "Content-Type: application/json" -d "$CONTEXT" "$EVALUATE_URL")"
FALLBACKS="$(jq -r '.flags' <<< "$INPUT")"

jq -src '.[1] as $results | .[0] | to_entries | map(., {key: .key, value: ($results[.key].value // .value | tostring)}) | from_entries' <(cat <<<"$FALLBACKS") <(cat <<<"$RESULTS")
