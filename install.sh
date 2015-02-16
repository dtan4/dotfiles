#!/bin/bash

echo "                                                      "
echo "                __      __  _____ __                  "
echo "           ____/ /___  / /_/ __(_) /__  _____         "
echo "          / __  / __ \/ __/ /_/ / / _ \/ ___/         "
echo "         / /_/ / /_/ / /_/ __/ / /  __(__  )          "
echo "         \__,_/\____/\__/_/ /_/_/\___/____/           "
echo "                                             by @dtan4"
echo "                                                      "
echo "                                                      "

echo "* Check Ruby..."

if [ ! $(which ruby) ]; then
    echo "- Ruby is not found."
    echo "You need to install Ruby"
fi

echo "+ Ruby is found."
echo "    version: $(ruby -v)"

echo ""

echo "* Install dotfiles..."
rake install
echo "+ Finish."
