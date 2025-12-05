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
    gradle.projectsEvaluated {
        tasks.withType(Checkstyle).configureEach { checkstyleTask ->
            checkstyleTask.classpath = files()
        }
    }
}
EOF
export JAVA_OPTS="-Xmx2g"
./gradlew checkstyleMain checkstyleTest \
  --no-parallel \
  --system-prop org.gradle.jvmargs=-Xmx2g \
  --init-script customConfig.gradle \
  --project-prop checkstyleVersion="${CS_POM_VERSION}"
removeFolderWithProtectedFiles kafka
