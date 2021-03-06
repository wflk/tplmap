#!/bin/bash

gradle -v >/dev/null 2>&1 || { echo >&2 "Gradle required but it's not installed.  Aborting."; exit 1; }
type nc >/dev/null 2>&1 || { echo >&2 "Netcat required but it's not installed.  Aborting."; exit 1; }

mkdir -p ./env_java_tests/lib/ 2> /dev/null

if [ ! -d ./env_java_tests/lib/spark-example/ ]; then
  rm  -rf ./env_java_tests/lib/spark-app/
  cp -rf ./env_java_tests/spark-app ./env_java_tests/lib/spark-app/
fi

cd ./env_java_tests/lib/spark-app/
gradle run &
GRADLEPID=$!

while ! echo exit | nc localhost 15003; do sleep 3; done

cd ../../../
python -m unittest discover . 'test_java_*.py'
sleep 1
# Shutdown Java webserver
kill ${GRADLEPID}
