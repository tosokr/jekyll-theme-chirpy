#!/bin/bash

#cd /srv/jekyll
#mkdir .jekyll-cache
#touch Gemfile.lock
#chmod a+w Gemfile.lock
#bundle config disable_platform_warnings true
#jekyll build --trace

set -eu

CMD="JEKYLL_ENV=production bundle exec jekyll b"

WORK_DIR=$(dirname $(dirname $(realpath "$0")))

CONTAINER=${WORK_DIR}/.container

DEST=${WORK_DIR}/_site


help() {
  echo "Usage:"
  echo
  echo "   bash build.sh [options]"
  echo
  echo "Options:"
  echo "   -b, --baseurl <URL>      The site relative url that start with slash, e.g. '/project'"
  echo "   -h, --help               Print the help information"
  echo "   -d, --destination <DIR>  Destination directory (defaults to ./_site)"
}


pythoninstall()
{
    echo "**** install Python ****" && \
    apk add --no-cache python3 python3-dev && \
    if [ ! -e /usr/bin/python ]; then ln -sf python3 /usr/bin/python ; fi && \
    \
    echo "**** install pip ****" && \
    python3 -m ensurepip && \
    rm -r /usr/lib/python*/ensurepip && \
    pip3 install --no-cache --upgrade pip setuptools wheel && \
    if [ ! -e /usr/bin/pip ]; then ln -s pip3 /usr/bin/pip ; fi
    pip install ruamel.yaml
}

fixcontainererrors(){
    mkdir .jekyll-cache
    touch Gemfile.lock
    chmod a+w Gemfile.lock
    bundle config disable_platform_warnings true
}
init() {
    pythoninstall
    cd $WORK_DIR
    fixcontainererrors

  if [[ -d $CONTAINER ]]; then
    rm -rf $CONTAINER
  fi

  if [[ -d _site ]]; then
    jekyll clean
  fi

  temp=$(mktemp -d)
  cp -r * $temp
  cp -r .git $temp
  mv $temp $CONTAINER
}


build() {
  cd $CONTAINER
  echo "$ cd $(pwd)"
  python _scripts/py/init_all.py

  CMD+=" -s ${CONTAINER} -d ${DEST} --trace"
  echo "\$ $CMD"
  eval $CMD
  echo -e "\nBuild success, the site files have been placed in '${DEST}'."

  if [[ -d ${DEST}/.git ]]; then
    if [[ ! -z $(git -C $DEST status -s) ]]; then
      git -C $DEST add .
      git -C $DEST commit -m "[Automation] Update site files." -q
      echo -e "\nPlease push the changes of $DEST to remote master branch.\n"
    fi
  fi

  cd .. && rm -rf $CONTAINER
}


check_unset() {
  if [[ -z ${1:+unset} ]]
  then
    help
    exit 1
  fi
}

test(){
    #Execute tests
    cd ${WORK_DIR}
    tools/test.sh
}

main() {
  while [[ $# -gt 0 ]]
  do
    opt="$1"
    case $opt in
      -b|--baseurl)
        check_unset $2
        if [[ $2 == \/* ]]
        then
          CMD+=" -b $2"
        else
          help
          exit 1
        fi
        shift
        shift
        ;;
      -d|--destination)
        check_unset $2
        DEST=$(realpath $2)
        shift;
        shift;
        ;;
      -h|--help)
        help
        exit 0
        ;;
      *) # unknown option
        help
        exit 1
        ;;
    esac
  done

  init
  build
  test
}

main "$@"