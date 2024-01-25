#!/usr/bin/env bash
set -ex

echo ---
env|grep GITHUB
echo ---
git --no-pager log --decorate=short --pretty=oneline
echo ---

INPUT_BASE_DIR=$1
INPUT_DIFF_FILTER=$2

if [ "${GITHUB_EVENT_NAME}" == "pull_request" ]; then
  BASE_REF=$(git rev-parse origin/${GITHUB_BASE_REF})
  HEAD_REF=$(git rev-parse HEAD)
elif  [ "${GITHUB_EVENT_NAME}" == "push" ]; then
  BASE_REF=HEAD
  HEAD_REF="HEAD^"
fi

echo DEBUG BASE_REF   : "${BASE_REF}"
echo DEBUG HEAD_REF   : "${HEAD_REF}"
echo DEBUG BASE_DIR   : "${INPUT_BASE_DIR}"
echo DEBUG DIFF_FILTER: "${INPUT_DIFF_FILTER}"

echo "XXXXX"
git --no-pager \
  diff \
  --name-only \
  --diff-filter="${INPUT_DIFF_FILTER}" \
  "${BASE_REF}" \
  "${HEAD_REF}"

echo "XXXXX"
AOUTPUT_TMP=$(
  git --no-pager \
    diff \
    --name-only \
    --diff-filter="${INPUT_DIFF_FILTER}" \
    "${BASE_REF}" \
    "${HEAD_REF}" | \
  grep ^"${INPUT_BASE_DIR}" | \
  xargs -n 1 dirname | \
  awk -F/ '{print $2}' | \
  sort | \
  uniq | \
  jq --raw-input . | \
  jq --slurp . | \
  tr -d "\ \n\r"
)
echo "DEBUG: ${AOUTPUT_TMP}"
echo "dirs=${AOUTPUT_TMP}">>"${GITHUB_OUTPUT}"
