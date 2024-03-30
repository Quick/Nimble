#!/bin/zsh

GIT_ROOT=$(git rev-parse --show-toplevel)
pushd "${GIT_ROOT}" 2>&1 >/dev/null

export DOCC_JSON_PRETTYPRINT="YES"

swift package --allow-writing-to-directory docs \
    generate-documentation --target Nimble \
    --disable-indexing \
    --transform-for-static-hosting \
    --hosting-base-path 'https://quick.github.io/Nimble' \
    --output-path docs

popd
