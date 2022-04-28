#!/bin/bash

dest_cache_file=$(brew --cache amax.rb) \
  && [[ "X${dest_cache_file}" != "X" ]] \
  && cp -v amax-0.5.0.monterey.bottle.tar.gz "${dest_cache_file}"

brew install amax.rb
