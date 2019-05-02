#!/bin/bash
error_code=0
for file in docker-compose*.test.yml
do
    echo "Running tests from ${file}"
	docker-compose -f "${file}" up --force-recreate --exit-code-from sut --abort-on-container-exit --no-color
	
	if [ $? != 0 ]
	then
		echo "Tests from ${file} failed"
		error_code=1
	else
	    echo "Tests from ${file} passed"
	fi
done
if [ $error_code != 0 ]
then
	echo "Some Tests failed"
else
    echo "All Tests passed"
fi

exit $error_code