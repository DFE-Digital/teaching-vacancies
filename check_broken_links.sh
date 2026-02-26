#!/bin/bash -e

# parameters 1 - base URL 2 - user - 3 password

# grab sitemap and roughly parse it into a link of pages to be passed to wget spider-mode
# Try not to spider school sites or big slow govuk ones.

# get-information-schools.service.gov.uk refuses to be spidered (via GitHub))
# can't check broken links to their domain
# signin.education.co.uk and friends don't respond to robots.txt
#
# we need -P option, otherwise lots of empty directories get created
# decided to specify a rate limit rather than a delay (-w) between pages
#
# teaching-jobs-in- filters out the location landing pages
# -teacher-jobs filters out the subject landing pages
#
# www.stem.org.uk seems to refuse Github access to robots.txt
# www.iop.org homepage reports as missing from github
# womened.com homepage reports as missing from github
# services.signin.education.gov.uk doesn't provide robots.txt
# nationalarchives.gov.uk seems to bring in a lot of noise
#
download_dir=$(mktemp -d)
# make sure script cleans up after itself
# from https://stackoverflow.com/questions/10982911/creating-temporary-files-in-bash
trap 'rm -rf "$download_dir"; exit' ERR EXIT  # HUP INT TERM
wget --auth-no-challenge -q --user=$2 --password=$3 $1/sitemap.xml -O - \
  | fgrep loc \
  | fgrep -v teaching-jobs-in- \
  | fgrep -v "\-teacher-jobs" \
  | fgrep -v "/jobs/" \
  | sed s'/    <loc>//' \
  | sed s'/<\/loc>//' \
  | wget -nv -np -H -r -t5 -l1 -i - --user=$2 --password=$3 \
  -P $download_dir \
  --spider \
  --limit-rate=200k \
  --exclude-directories="assets" \
  --auth-no-challenge \
  --no-relative \
  --exclude-domains="womened.com,www.iop.org,www.stem.org.uk,get-information-schools.service.gov.uk,services.signin.education.gov.uk,nationalarchives.gov.uk"
