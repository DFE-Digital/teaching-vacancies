#!/bin/bash -e

# parameters 1 - base URL 2 - user - 3 password

# grab sitemap and roughly parse it into a link of pages to be passed to wget spider-mode
# Try not to spider school sites or big slow govuk ones.

# get-information-schools.service.gov.uk refuses to be spidered so we
# can't check broken links to their domain
# signin.education.co.uk and friends don't respond to robots.txt
#
# we need -P option, otherwise lots of empty directories get created
#
# teaching-jobs-in- filters out the location landing pages
# -teacher-jobs filters out the subject landing pages
wget --auth-no-challenge -q --user=$2 --password=$3 $1/sitemap.xml -O - \
  | fgrep loc \
  | fgrep -v teaching-jobs-in- \
  | fgrep -v "\-teacher-jobs" \
  | fgrep -v "/jobs/" \
  | sed s'/    <loc>//' \
  | sed s'/<\/loc>//' \
  | wget -nv -np -w 0.1 --spider -H -r -l1 -i - --user=$2 --password=$3 \
  -P /tmp/spider \
  --auth-no-challenge \
  --no-relative \
  --exclude-domains="signin.education.gov.uk,get-information-schools.service.gov.uk,ofsted.gov.uk,nationalarchives.gov.uk"
