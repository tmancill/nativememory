#!/bin/bash

./gradlew clean shadowJar

echo ========================================================================
echo
echo Ubuntu + AdoptOpenJDK 8, unset MALLOC_TRIM_THRESHOLD_
echo
docker run -ti -v $(pwd):/tmp/nativememory adoptopenjdk:8u232-b09-jre-hotspot bash -c "apt-get update >/dev/null && apt-get -y install procps >/dev/null &cd /tmp/nativememory && unset MALLOC_TRIM_THRESHOLD_ && ./run.sh 4096 1 4"
echo
echo
echo ========================================================================
echo
echo Ubuntu + AdoptOpenJDK 8, MALLOC_TRIM_THRESHOLD_=200000000
echo
docker run -ti -v $(pwd):/tmp/nativememory adoptopenjdk:8u232-b09-jre-hotspot bash -c "apt-get update >/dev/null && apt-get -y install procps >/dev/null &cd /tmp/nativememory && export MALLOC_TRIM_THRESHOLD_=200000000 && ./run.sh 4096 1 4"

echo
echo ========================================================================
echo
echo Ubuntu + Ubuntu OpenJDK 8, unset MALLOC_TRIM_THRESHOLD_
echo
docker run -ti -v $(pwd):/tmp/nativememory ubuntu:18.04 bash -c "export DEBIAN_FRONTEND=noninteractive && apt-get update >/dev/null && apt-get -y install openjdk-8-jre-headless procps >/dev/null && cd /tmp/nativememory && unset MALLOC_TRIM_THRESHOLD_ && ./run.sh 4096 1 4"

echo
echo ========================================================================
echo
echo Ubuntu + AdoptOpenJDK 11, unset MALLOC_TRIM_THRESHOLD_
echo
docker run -ti -v $(pwd):/tmp/nativememory adoptopenjdk:11.0.6_10-jre-hotspot bash -c "apt-get update >/dev/null && apt-get -y install procps >/dev/null &cd /tmp/nativememory && unset MALLOC_TRIM_THRESHOLD_ && ./run.sh 4096 1 4"
