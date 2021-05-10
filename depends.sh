#! /bin/sh
cd prebuild/arm64
for i in *.deb; do
  r=$(dpkg-deb -f $i Depends | grep $1)
  if [ "$r" != "" ]; then
    echo $i
  fi
done
