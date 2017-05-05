#!/bin/ash
echo "Running maven strategy"
echo "Docker tmp dir: ${DOCKER_SOURCE_DIR}"
if [ ! -e "${DOCKER_SOCKET}" ]; then
  echo "Docker socket missing at ${DOCKER_SOCKET}"
  exit 1
fi
cd /maven
MAVEN_SOURCE_DIR=$(mktemp -d)
git clone --recursive ${SOURCE_REPOSITORY} ${MAVEN_SOURCE_DIR}
if [ $? != 0 ]; then
        echo "Error trying to fetch git srouce: ${SOURCE_REPOSITORY}"
        exit 1
fi

cd $MAVEN_SOURCE_DIR
git checkout ${SOURCE_REF}
if [ $? != 0 ]; then
        echo "Error trying to checkout ref: ${SOURCE_REF}"
        exit 1
fi      
if [ -n "${SOURCE_CONTEXT_DIR}" ]; then
        cd ${SOURCE_CONTEXT_DIR}
fi
mvn clean install -DskipTests=true
if [ $? != 0 ]; then
	echo "Maven build exited with error"
	exit 1
fi
rm -f target/*sources.jar
mv target/*.jar ${DOCKER_SOURCE_DIR}/app.jar
if [ -n "${SOURCE_CONTEXT_DIR}" ]; then
        cd ..
fi
cd ..
cp ${STRATEGY_FOLDER}/maven/Dockerfile.part ${DOCKER_SOURCE_DIR}
if [ $? != 0 ]; then
	echo "Could not copy Dockerfile.part"
	exit 1
fi
echo "maven strategy done"
