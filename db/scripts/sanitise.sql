TRUNCATE TABLE alert_runs;
TRUNCATE TABLE emergency_login_keys;
TRUNCATE TABLE sessions;

-- Columns encrypted with lockbox should be set to values that can be decrypted by the target environment.
-- These values are encrypted with the staging lockbox master key.
-- Change them if you are using this script for a different environment, as the key will be different.
-- There are multiple values in order to pass the different validations on each attribute.
SET lorem_string_ciphertext = 'London'
SET lorem_phone_number_ciphertext
SET lorem_email_ciphertext
SET lorem_teacher_reference_number_ciphertext
SET lorem_national_insurance_number_ciphertext
SET empty_string_ciphertext

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
           email=concat('anonymised-feedback-',id,'@example.org'),  -- encrypt. doesn't need id
           other_unsubscribe_reason_comment=NULL,
           visit_purpose_comment=NULL;

UPDATE job_applications
       SET first_name='Anonymous', -- encrypt
           last_name='Anon', -- encrypt
           previous_names='', -- encrypt
           street_address='1 Example Street', -- encrypt
           city='Anonymised City', -- encrypt
           postcode='P05T C0DE', -- encrypt
           phone_number='01234567890',  -- encrypt
           teacher_reference_number='1234567',  -- encrypt
           national_insurance_number='QQ 12 34 56 C', -- encrypt
           personal_statement='Lorem ipsum dolor sit amet', -- encrypt
           support_needed_details='', -- encrypt
           close_relationships_details='', -- encrypt
           further_instructions='', -- encrypt
           rejection_reasons='', -- encrypt
           gaps_in_employment_details='', -- encrypt
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
       SET email=concat('anonymised-jobseeker-',id,'@example.org'), -- encrypt, and account for email LIKE '%education'
           encrypted_password='ABCDEFGH12345',
           reset_password_token=concat('anonymised-reset-password-token-',id),
           current_sign_in_ip='8.8.8.8',
           last_sign_in_ip='8.8.4.4',
           confirmation_token=concat('anonymised-confirmation-token-',id),
           unconfirmed_email='', -- encrypt
           unlock_token=concat('anonymised-unlock-token-',id)
       WHERE email NOT LIKE '%education.gov.uk';

UPDATE publishers
       SET email=concat('anonymised-publisher-',id,'@example.org'), -- encrypt. no need for unique
           family_name='anon', -- encrypt
           given_name='anon'; -- encrypt
           oid=;  -- encrypt (and add to sanitise.sql) (must match the original record)

UPDATE qualifications
       SET finished_studying_details='';

UPDATE "references"
       SET name='Anonymous Anon',
           job_title='Example Job Title',
           email='anon@example.org',
           phone_number='01234567890';

UPDATE subscriptions
       SET email=concat('anonymised-subscription-',id,'@example.org');
