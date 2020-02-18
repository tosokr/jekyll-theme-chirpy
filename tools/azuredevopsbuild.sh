#!/bin/bash
cd /srv/jekyll
mkdir .jekyll-cache
touch Gemfile.lock
chmod a+w Gemfile.lock
bundle config disable_platform_warnings true
jekyll build --trace

#Execute tests
bundle exec htmlproofer _site \
  --disable-external \
  --check-html \
  --empty_alt_ignore \
  --allow_hash_href \
  --url_ignore cdn.jsdelivr.net