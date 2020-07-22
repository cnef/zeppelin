#!/bin/bash 

set -x
set -e

mvn package -DskipTests -Pbuild-distr