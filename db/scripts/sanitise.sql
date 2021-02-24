TRUNCATE TABLE alert_runs;
TRUNCATE TABLE emergency_login_keys;
TRUNCATE TABLE sessions;

UPDATE feedbacks
       SET comment=NULL,
           email=concat('anonymised-feedback-',id,'@example.org'),
           other_unsubscribe_reason_comment=NULL,
           visit_purpose_comment=NULL;

UPDATE jobseekers
       SET email=concat('anonymised-jobseeker-',id,'@example.org'),
           encrypted_password='ABCDEFGH12345',
           reset_password_token='12345ABCDEFGH',
           current_sign_in_ip='8.8.8.8',
           last_sign_in_ip='8.8.4.4',
           confirmation_token='CDEFGHIJ34567',
           unconfirmed_email=concat('anonymised-jobseeker-',id,'@example.org'),
           unlock_token='34567CDEFGHIJ'
       WHERE email NOT LIKE '%education.gov.uk';

UPDATE publishers
       SET email=concat('anonymised-publisher-',id,'@example.org'),
           family_name='anon',
           given_name='anon';

UPDATE subscriptions
       SET email=concat('anonymised-subscription-',id,'@example.org');
