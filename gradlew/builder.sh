#!/bin/ash
echo "Running gradlen strategy"
echo "Docker tmp dir: ${DOCKER_SOURCE_DIR}"
if [ ! -e "${DOCKER_SOCKET}" ]; then
  echo "Docker socket missing at ${DOCKER_SOCKET}"
  exit 1
fi
GRADLE_SOURCE_DIR=$(mktemp -d)
git clone --recursive ${SOURCE_REPOSITORY} ${GRADLE_SOURCE_DIR}
if [ $? != 0 ]; then
        echo "Error trying to fetch git srouce: ${SOURCE_REPOSITORY}"
        exit 1
fi

cd $GRADLE_SOURCE_DIR
git checkout ${SOURCE_REF}
if [ $? != 0 ]; then
        echo "Error trying to checkout ref: ${SOURCE_REF}"
        exit 1
fi
if [ -n "${SOURCE_CONTEXT_DIR}" ]; then
        cd ${SOURCE_CONTEXT_DIR}
fi
./gradlew build -x test
if [ $? != 0 ]; then
	echo "Gradle build exited with error"
	exit 1
fi
mv build/libs/*.jar ${DOCKER_SOURCE_DIR}/app.jar
if [ -n "${SOURCE_CONTEXT_DIR}" ]; then
        cd ..
fi
cd ..
cp ${STRATEGY_FOLDER}/maven/Dockerfile.part ${DOCKER_SOURCE_DIR}
if [ $? != 0 ]; then
	echo "Could not copy Dockerfile.part"
	exit 1
fi
echo "gradle strategy done"
