#!/usr/bin/env bash
#
echo ""
echo "-------------------------------install sdks and language runtimes-----------------------------------"
curl -s "https://get.sdkman.io" | bash
source "$HOME/.sdkman/bin/sdkman-init.sh"
echo ""

echo ""
echo "-------------------------------update sdkman and packages-----------------------------------"
sdk selfupdate
sdk update
echo ""

echo ""
echo "-------------------------------install language, runtimes and frameworks-----------------------------------"
sdk install java
sdk install groovy
sdk install scala
sdk install kotlin
sdk install springboot
sdk install grails
sdk install visualvm
sdk install sbt
echo ""