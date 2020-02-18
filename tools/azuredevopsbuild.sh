#!/bin/bash
cd /srv/jekyll
touch Gemfile.lock
chmod a+w Gemfile.lock
JEKYLL_ENV=production bundle exec jekyll b