#!/bin/bash
cd /srv/jekyll
touch Gemfile.lock
chmod a+w Gemfile.lock
jekyll build