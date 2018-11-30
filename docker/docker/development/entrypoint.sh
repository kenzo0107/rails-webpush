#!/bin/bash

set -eu

basedir=$(dirname $0)/../../bin

echo '== Checking database existence =='
if bin/rake db:version &> /dev/null ; then
  echo '🙆‍ Database exists. Invoking bin/update'
  $basedir/update
else
  echo '🙅 Database does not exist. Invoking bin/setup'
  $basedir/setup
fi

# echo '== Starting webpack-dev-server =='
# $basedir/webpack-dev-server &

echo '== Starting application server =='
$basedir/rails server
