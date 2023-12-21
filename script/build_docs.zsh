#!/bin/zsh

#  Created by Jesse Squires
#  https://www.jessesquires.com
#
#  Copyright © 2020-present Jesse Squires
#
#  Jazzy: https://github.com/realm/jazzy/releases/latest
#  Generates documentation using jazzy and checks for installation.

bundle exec jazzy \
    --clean \
    --author "Nimble Contributors" \
    --author_url "https://github.com/Quick/Nimble" \
    --github_url "https://github.com/Quick/Nimble" \
    --module "Nimble" \
    --source-directory . \
    --readme "README.md" \
    -x -scheme,Nimble \
    --output docs/
