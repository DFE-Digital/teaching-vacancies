TRUNCATE TABLE alert_runs;
TRUNCATE TABLE emergency_login_keys;
TRUNCATE TABLE sessions;

UPDATE employments
       SET organisation='Example Organisation',
           job_title='Example Job Title',
           main_duties='Lorem ipsum dolor sit amet';

UPDATE equal_opportunities_reports
       SET disability_no=0,
           disability_prefer_not_to_say=0,
           disability_yes=0,
           gender_man=0,
           gender_other=0,
           gender_prefer_not_to_say=0,
           gender_woman=0,
           gender_other_descriptions=ARRAY[]::varchar[],
           orientation_bisexual=0,
           orientation_gay_or_lesbian=0,
           orientation_heterosexual=0,
           orientation_other=0,
           orientation_prefer_not_to_say=0,
           orientation_other_descriptions=ARRAY[]::varchar[],
           ethnicity_asian=0,
           ethnicity_black=0,
           ethnicity_mixed=0,
           ethnicity_other=0,
           ethnicity_prefer_not_to_say=0,
           ethnicity_white=0,
           ethnicity_other_descriptions=ARRAY[]::varchar[],
           religion_buddhist=0,
           religion_christian=0,
           religion_hindu=0,
           religion_jewish=0,
           religion_muslim=0,
           religion_none=0,
           religion_other=0,
           religion_prefer_not_to_say=0,
           religion_sikh=0,
           religion_other_descriptions=ARRAY[]::varchar[];

UPDATE feedbacks
       SET comment=NULL,
           email=concat('anonymised-feedback-',id,'@example.org'),
           other_unsubscribe_reason_comment=NULL,
           visit_purpose_comment=NULL;

UPDATE job_applications
       SET first_name='Anonymous',
           last_name='Anon',
           previous_names='',
           street_address='1 Example Street',
           city='Anonymised City',
           postcode='P05T C0DE',
           phone_number='01234567890',
           teacher_reference_number='1234567',
           national_insurance_number='QQ 12 34 56 C',
           personal_statement='Lorem ipsum dolor sit amet',
           support_needed_details='',
           close_relationships_details='',
           further_instructions='',
           rejection_reasons='',
           gaps_in_employment_details='',
           disability='prefer_not_to_say',
           gender='prefer_not_to_say',
           gender_description='',
           orientation='prefer_not_to_say',
           orientation_description='',
           ethnicity='prefer_not_to_say',
           ethnicity_description='',
           religion='prefer_not_to_say',
           religion_description='';

UPDATE jobseekers
       SET email=concat('anonymised-jobseeker-',id,'@example.org'),
           encrypted_password='ABCDEFGH12345',
           reset_password_token=concat('anonymised-reset-password-token-',id),
           current_sign_in_ip='8.8.8.8',
           last_sign_in_ip='8.8.4.4',
           confirmation_token=concat('anonymised-confirmation-token-',id),
           unconfirmed_email='',
           unlock_token=concat('anonymised-unlock-token-',id)
       WHERE email NOT LIKE '%education.gov.uk';

UPDATE publishers
       SET email=concat('anonymised-publisher-',id,'@example.org'),
           family_name='anon',
           given_name='anon';

UPDATE qualifications
       SET finished_studying_details='';

UPDATE "references"
       SET name='Anonymous Anon',
           job_title='Example Job Title',
           email='anon@example.org',
           phone_number='01234567890';

UPDATE subscriptions
       SET email=concat('anonymised-subscription-',id,'@example.org');
