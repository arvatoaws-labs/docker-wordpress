#!/bin/bash

arch=`uname -m`

case $arch in
  x86_64)
  case $1 in
    x)
      echo 'x86_64'
    ;;
    a)
      echo 'amd64'
    ;;
  esac
  ;;

  aarch64)
  case $2 in
    r)
      echo 'arm64'
    ;;
    c)
      echo 'aarch64'
    ;;
  esac
  ;;

esac
