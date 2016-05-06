#!/bin/bash
# This script is used to build and try test cases during development

#          OPTIONS="Hello Quit"
#          select opt in $OPTIONS; do
#              if [ "$opt" = "Quit" ]; then
#               echo done
#               exit
#              elif [ "$opt" = "Hello" ]; then
#               echo Hello World
#              else
#               clear
#               echo bad option
#              fi
#          done
## ** Script for testing os **
# Credit https://stackoverflow.com/questions/3466166/how-to-check-if-running-in-cygwin-mac-or-linux/17072017#17072017?newreg=b1cdf253d60546f0acfb73e0351ea8be
function testOS {
  if [ "$(uname)" == "Darwin" ]; then
      # Do something under Mac OS X platform
      echo MacOsX
  elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
      # Do something under GNU/Linux platform
      echo Linux
  elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW32_NT" ]; then
      # Do something under Windows NT platform
      echo Windows
  fi
}

testOS

function counter {
  runningContainers="$(docker ps -a -q)" #"$(docker images -aq)"  #"$(docker ps -qf STATUS=exited )" #"$(docker ps -q)"
  length=${#runningContainers[@]}
  number_of_occurrences=$(grep -o "" <<< "$runningContainers" | wc -l)
  echo $runningContainers
  echo $number_of_occurrences
  declare -p $runningContainers 2> /dev/null | grep -q '^declare \-a' && echo array || echo array not found

}

function networks {
    echo NETWORKS
    IFS=$'\n' read -rd '' -a networks <<<"$(docker network ls -q)"
	declare -a emptyNetworks
	for i in "${networks[@]}"; do
		containers="$(docker network inspect -f '{{json .Containers}}' "$i")"
        containers=${containers:3}
        if [[ -z $containers ]]; then
            echo EMTPY
        fi
        echo Container: ${containers}
		name="$(docker network inspect -f '{{json .Name}}' "$i")"
		if [[ -n "$containers" ]] && [[ "$name" != '"bridge"' ]] && [[ "$name" != '"host"' ]] && [[ "$name" != '"none"' ]]; then
            echo "$i"
            emptyNetworks+=("$i")
		fi
	done
}

#networks
#echo $running_Count

function countTest {
    echo got here
		toCount="$1"
    echo arg passed: $toCount
    size=$((${#toCount} % 12 ))
    size=$size
    echo $size
    number=$toCount | grep -o " " | wc -l
		#number_of_occurrences=$(grep -o "" <<< "$toCount" | wc -l)
		echo $number_of_occurrences
}
#unningContainers="$(docker ps -a -q)"
#number=$(count "$runningContainers")
#echo $number
#count
function count {
		toCount="$1"
    length=${#toCount}
		## Works on OSX, not Linux
		#number_of_occurrences=$(grep -o "" <<< "$toCount" | wc -l)

    if [[ $length != 0 ]]; then
      number_of_occurrences=$(($length % 12 + 1))
		fi
		echo $number_of_occurrences
}

function cleanContainers {
    stoppedContainers="$(docker ps -qf STATUS=exited )"
		createdContainers="$(docker ps -qf STATUS=created)"
		stopped_count=$(count stoppedContainers)
		created_count=$(count createdContainers)
    if [ ! "$stoppedContainers" ]; then
        echo No Containers To Clean!
    else
				echo Cleaning containers...
        docker rm $stoppedContainers &>/dev/null
				echo Stopped containers cleaned: $stopped_count
    fi

		if [ "$createdContainers" ]; then
			docker rm $createdContainers &>/dev/null
			echo Created containers cleaned: $created_count
		fi
}

function arrayContains {
		for i in "${@:2}"; do
			[[ "$i" == "$1" ]] && return 0;
		done
		return 1
}


function build() {
    if [ "$(docker ps -a -q)" ]; then
      docker rm -f $(docker ps -a -q)
    fi
     docker pull zzrot/whale-awkward
     docker pull zzrot/alpine-caddy
     docker pull zzrot/alpine-node
     docker run -d -P --name extra -v /webapp zzrot/alpine-caddy
     docker run -d -P --name web -v /webapp training/webapp python app.py
     docker network create testNet
     docker network create testNet2
     docker network connect testNet web
     docker network connect testNet2 extra
    #run docker run -d ghost
    #run docker run -d alpine-caddy
    #run docker kill ghost
}
containsElement () {
  local e
  for e in "${@:2}"; do [[ "$e" == "$1" ]] && return 0; done
  return 1
}

array=("something to search for" "a string" "test2000")
arrayContains "a string" "${array[@]}"
#echo $?
build
#images=$(docker images -a -q)
#echo ${#images}
#../docker-clean --images
#after=$(docker images -a -q)
#echo ${#after}
#count "$(docker images -a -q)"
#count "$(docker ps -a -q)"

# Verbosity testing
