#!/bin/bash
cd /srv/jekyll
mkdir .jekyll-cache
touch Gemfile.lock
chmod a+w Gemfile.lock
bundle config disable_platform_warnings true
jekyll build --trace