#!/bin/bash -e

# parameters 1 - base URL 2 - user - 3 password

# grab sitemap and roughly parse it into a link of pages to be passed to wget spider-mode
# Try not to spider school sites or big slow govuk ones.

# get-information-schools.service.gov.uk refuses to be spidered (via GitHub))
# can't check broken links to their domain
# signin.education.co.uk and friends don't respond to robots.txt
#
# we need -P option, otherwise lots of empty directories get created
# -w specifies a wait between pages of 0.2 seconds
#
# teaching-jobs-in- filters out the location landing pages
# -teacher-jobs filters out the subject landing pages
#
# www.stem.org.uk seems to refuse Github access to robots.txt
# www.iop.org homepage reports as missing from github
# womened.com homepage reports as missing from github
#
wget --auth-no-challenge -q --user=$2 --password=$3 $1/sitemap.xml -O - \
  | fgrep loc \
  | fgrep -v teaching-jobs-in- \
  | fgrep -v "\-teacher-jobs" \
  | fgrep -v "/jobs/" \
  | sed s'/    <loc>//' \
  | sed s'/<\/loc>//' \
  | wget -nv -np -w 0.2 --spider -H -r -l1 -i - --user=$2 --password=$3 \
  -P /tmp/spider \
  --auth-no-challenge \
  --no-relative \
  --exclude-domains="womened.com,www.iop.org,www.stem.org.uk,get-information-schools.service.gov.uk"
