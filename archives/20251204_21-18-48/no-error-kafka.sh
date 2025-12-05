#!/usr/bin/env bash

set -e

source ./.ci/util.sh

CS_POM_VERSION="$(getCheckstylePomVersion)"
echo CS_version: "${CS_POM_VERSION}"
./mvnw -e --no-transfer-progress clean install -Pno-validations
echo "Checkout Apache Kafka sources ..."
checkout_from https://github.com/apache/kafka
cd .ci-temp/kafka
cat >> customConfig.gradle<< EOF
allprojects {
    repositories {
        mavenLocal()
    }
}
EOF
./gradlew checkstyleMain checkstyleTest \
  -Dorg.gradle.jvmargs="-XX:MaxHeapSize=2g" \
  --init-script customConfig.gradle \
  --project-prop checkstyleVersion="${CS_POM_VERSION}"
removeFolderWithProtectedFiles kafka
