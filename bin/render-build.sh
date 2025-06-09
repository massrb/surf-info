#!/usr/bin/env bash

# Exit on error
set -o errexit

apt-get update && apt-get install -y \
  libgtk-4-1 \
  libgraphene-1.0-0 \
  libgstreamer-gl1.0-0 \
  gstreamer1.0-plugins-bad \
  libenchant-2-2 \
  libsecret-1-0 \
  libmanette-0.2-0 \
  libgles2
  
bundle install
playwright install
bin/rails assets:precompile
bin/rails assets:clean

# If you have a paid instance type, we recommend moving
# database migrations like this one from the build command
# to the pre-deploy command:
bin/rails db:migrate