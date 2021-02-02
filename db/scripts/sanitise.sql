TRUNCATE TABLE audit_data;
TRUNCATE TABLE emergency_login_keys;
TRUNCATE TABLE sessions;

UPDATE account_feedbacks
       SET suggestions=NULL;

UPDATE general_feedbacks
       SET comment=NULL,
           email=concat('anonymised-feedback-',id,'@example.org')

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

UPDATE job_alert_feedbacks
        SET comment=NULL;

UPDATE publishers
       SET email=concat('anonymised-publisher-',id,'@example.org'),
           family_name='anon',
           given_name='anon';

UPDATE subscriptions
       SET email=concat('anonymised-subscription-',id,'@example.org');

UPDATE unsubscribe_feedbacks
       SET other_reason=NULL,
           additional_info=NULL;
