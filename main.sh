#!/usr/bin/env bash
set -ex

echo ---
env|grep GITHUB
echo ---
git --no-pager log --decorate=short --pretty=oneline
echo ---

INPUT_BASE_REF=$1
INPUT_HEAD_REF=$2
INPUT_BASE_DIR=$3
INPUT_DIFF_FILTER=$4

echo DEBUG BASE_REF   : ${INPUT_BASE_REF}
echo DEBUG HEAD_REF   : ${INPUT_HEAD_REF}
echo DEBUG BASE_DIR   : ${INPUT_BASE_DIR}
echo DEBUG DIFF_FILTER: ${INPUT_DIFF_FILTER}


AOUTPUT_TMP=$(
  git diff \
    --name-only \
    --diff-filter=${INPUT_DIFF_FILTER} \
    ${INPUT_BASE_REF} \
    ${INPUT_HEAD_REF} | \
  grep ^${INPUT_BASE_DIR} | \
  xargs -n 1 dirname | \
  awk -F/ '{print $2}' | \
  sort | \
  uniq | \
  jq --raw-input . | \
  jq --slurp . | \
  tr -d "\ \n\r"
)
echo DEBUG: ${AOUTPUT_TMP}
echo "dirs=${AOUTPUT_TMP}">>${GITHUB_OUTPUT}
