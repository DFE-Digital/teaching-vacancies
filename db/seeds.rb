raise "Aborting seeds - running in production with existing vacancies" if Rails.env.production? && Vacancy.any?

require "faker"
require "factory_bot_rails"

Gias::ImportSchoolsAndLocalAuthorities.new.call
Gias::ImportTrusts.new.call

ImportPolygonDataJob.perform_now

bexleyheath_school = School.find_by!(urn: "137138")
weydon_trust = SchoolGroup.find_by!(uid: "16644")
southampton_la = SchoolGroup.find_by!(local_authority_code: "852")

# Publishers
attrs = { organisations: [bexleyheath_school, weydon_trust, southampton_la] }
Publisher.create(email: "alex.bowen@digital.education.gov.uk", family_name: "Bowen", given_name: "Alex", **attrs)
Publisher.create(email: "alex.wiskar@digital.education.gov.uk", family_name: "Wiskar", given_name: "Alex", **attrs)
Publisher.create(email: "ben.mitchell@digital.education.gov.uk", family_name: "Mitchell", given_name: "Ben", **attrs)
Publisher.create(email: "cesidio.dilanda@digital.education.gov.uk", family_name: "Di Landa", given_name: "Cesidio", **attrs)
Publisher.create(email: "christian.sutter@digital.education.gov.uk", family_name: "Sutter", given_name: "Christian", **attrs)
Publisher.create(email: "colin.saliceti@digital.education.gov.uk", family_name: "Saliceti", given_name: "Colin", **attrs)
Publisher.create(email: "danny.chadburn@digital.education.gov.uk", family_name: "Chadburn", given_name: "Danny", **attrs)
Publisher.create(email: "david.mears@digital.education.gov.uk", family_name: "Mears", given_name: "David", **attrs)
Publisher.create(email: "elliot.crosby-mccullough@digital.education.gov.uk", family_name: "Crosby-McCullough", given_name: "Elliot", **attrs)
Publisher.create(email: "ife.akinbolaji@digital.education.gov.uk", family_name: "Akinbolaji", given_name: "Ife", **attrs)
Publisher.create(email: "jesse.yuen@digital.education.gov.uk", family_name: "Yuen", given_name: "Jesse", **attrs)
Publisher.create(email: "joseph.hull@digital.education.gov.uk", family_name: "Hull", given_name: "Joseph", **attrs)
Publisher.create(email: "leonie.shanks@digital.education.gov.uk", family_name: "Shanks", given_name: "Leonie", **attrs)
Publisher.create(email: "mili.malde@digital.education.gov.uk", family_name: "Malde", given_name: "Mili", **attrs)
Publisher.create(email: "molly.capstick@digital.education.gov.uk", family_name: "Capstick", given_name: "Molly", **attrs)
Publisher.create(email: "rishil.patel@digital.education.gov.uk", family_name: "Patel", given_name: "Rishil", **attrs)
Publisher.create(email: "rose.mackworth-young@digital.education.gov.uk", family_name: "Mackworth-Young", given_name: "Rose", **attrs)
