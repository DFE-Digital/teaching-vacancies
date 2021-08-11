TRUNCATE TABLE alert_runs;
TRUNCATE TABLE emergency_login_keys;
TRUNCATE TABLE sessions;

UPDATE employments
       SET organisation_ciphertext='',
           job_title_ciphertext='',
           main_duties_ciphertext='';

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
       SET first_name_ciphertext='',
           last_name_ciphertext='',
           previous_names_ciphertext='',
           street_address_ciphertext='',
           city_ciphertext='',
           postcode_ciphertext='',
           phone_number_ciphertext='',
           teacher_reference_number_ciphertext='',
           national_insurance_number_ciphertext='',
           personal_statement_ciphertext='',
           support_needed_details_ciphertext='',
           close_relationships_details_ciphertext='',
           further_instructions_ciphertext='',
           rejection_reasons_ciphertext='',
           gaps_in_employment_details_ciphertext='',
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
           current_sign_in_ip_ciphertext='',
           last_sign_in_ip_ciphertext='',
           confirmation_token=concat('anonymised-confirmation-token-',id),
           unconfirmed_email='',
           unlock_token=concat('anonymised-unlock-token-',id)
       WHERE email NOT LIKE '%education.gov.uk';

UPDATE publishers
       SET email=concat('anonymised-publisher-',id,'@example.org'),
           family_name_ciphertext='',
           given_name_ciphertext='';

UPDATE qualifications
       SET finished_studying_details_ciphertext='';

UPDATE "references"
       SET name_ciphertext='',
           job_title_ciphertext='',
           email_ciphertext='',
           phone_number_ciphertext='';

UPDATE subscriptions
       SET email=concat('anonymised-subscription-',id,'@example.org');
