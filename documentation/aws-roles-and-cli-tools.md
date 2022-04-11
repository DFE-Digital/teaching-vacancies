# AWS credentials, MFA, and role profiles

When onboarded, you will be provided with an AWS user. You can use it to access the AWS console at:
[https://teaching-vacancies.signin.aws.amazon.com/console](https://teaching-vacancies.signin.aws.amazon.com/console).

- Log in to the console and go to [My Security Credentials](https://console.aws.amazon.com/iam/home?region=eu-west-2#/security_credentials).
- Choose `Assign MFA device` and set up an authenticator app as a Virtual MFA device.
- If using an Authenticator App, scan the QR code, and when prompted to enter codes, enter the first code, wait 30 seconds until a new code has been generated on your authenticator app, and enter the new code in the second box.
- Log out, and back in. You should be prompted for an MFA code.
- Go to [My Security Credentials](https://console.aws.amazon.com/iam/home?region=eu-west-2#/security_credentials).
- Choose `Create access key`. Note the credentials securely, as you will need these to configure the AWS CLI.

## Assuming a role in the console

- When you log in to AWS you will have permissions to
  - Change your password
  - Set up an MFA device
  - Generate Access Keys
To carry out more privileged operations, you will need to [switch to a role](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_use_switch-role-console.html)
- Choose your user name on the navigation bar in the upper right. It typically looks like this: <YOUR-AWS-USERNAME>@teaching-vacancies.
- Choose `Switch Roles`.
- For Account, enter `530003481352`
- For Role, enter `ReadOnly`
- For Display Name, this will be greyed out as `ReadOnly @ 530003481352`
- Pick a colour for the role display and click `Switch Role`
- Choose `Switch Roles` again
- For Account, enter `530003481352`
- For Role, enter `SecretEditor`
- For Display Name, this will be greyed out as `SecretEditor @ 530003481352`
- These two roles should now be listed in your Role History

## Roles

- `Administrator` can:
  - administer the AWS account, and all resources, including user and group management
- `BillingManager` can:
  - access invoices and other billing information
  - read all resources
- `Deployments` can:
  - deploy apps and resources
- `ReadOnly` can:
  - read all resources
- `SecretEditor` can:
  - read and update existing secrets within Parameter Store

## Tool installation

Install:
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
- [AWS Vault](https://github.com/99designs/aws-vault#installing)

### macOS

```bash
brew install awscli
brew install --cask aws-vault
```

### Ubuntu WSL2

The setup on Ubuntu is more involved, as we use GPG and [`pass`](https://www.passwordstore.org/) for a secure vault backend

Install AWS CLI v2
```bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip -q awscliv2.zip -d /tmp
sudo /tmp/aws/install
```
Install AWS Vault
```bash
wget https://github.com/99designs/aws-vault/releases/download/v6.2.0/aws-vault-linux-amd64
sudo mv ./aws-vault-linux-amd64 /usr/local/bin/aws-vault
sudo chmod +x /usr/local/bin/aws-vault
```
Install GPG and Pass
```bash
sudo apt-get install -y gnupg pass
```

There's an excellent guide to [managing password with GPG, the command line and Pass](https://www.thepolyglotdeveloper.com/2018/12/manage-passwords-gpg-command-line-pass/) but the essentials are:

#### Generate GPG Key

```bash
gpg --full-generate-key
```
Answer the interactive questions. I chose
```
Please select what kind of key you want:
   (1) RSA and RSA (default)
RSA keys may be between 1024 and 4096 bits long.
What keysize do you want? (3072)
    3072
Please specify how long the key should be valid.
         0 = key does not expire
      <n>  = key expires in n days
      <n>w = key expires in n weeks
      <n>m = key expires in n months
      <n>y = key expires in n years
Key is valid for? (0)
    2y
````
You are then prompted for some personal details
```
GnuPG needs to construct a user ID to identify your key.

Real name: <YOUR-NAME>
Email address: <YOUR-NAME>@digital.education.gov.uk
Comment: Work
You selected this USER-ID:
    "<YOUR-NAME> (Work) <<YOUR-NAME>@digital.education.gov.uk>"
```
You are then prompted for a passphrase to protect the GPG key. I used my Windows password manager to generate and store the passphrase

After moving the mouse to generate random bytes for prime generation, we see:
```
gpg: key 8C6B1A2FA5910DE0 marked as ultimately trusted
gpg: revocation certificate stored as '/home/nrubuntu/.gnupg/openpgp-revocs.d/A5896473017A0DD9B983A03D8C6B1A2FA5910DE0.rev'
public and secret key created and signed.

pub   rsa3072 2021-02-11 [SC] [expires: 2023-02-11]
      A5896473017A0DD9B983A03D8C6B1A2FA5910DE0
uid                      <YOUR-NAME> (Work) <<YOUR-NAME>@digital.education.gov.uk>
sub   rsa3072 2021-02-11 [E] [expires: 2023-02-11]
```

Typing `gpg --list-keys` will repeat the output of `pub`, `uid`, and `sub`

#### Secure password-store with GPG key

```bash
pass init <GPG-PUB-ID from step above>
```

Append to `~/.bashrc` or `~/.zshrc`
```
export AWS_VAULT_PASS_PREFIX=aws-vault
export AWS_VAULT_BACKEND=pass
```

## Configure AWS CLI with AWS Vault profiles

Edit or create the `~/.aws/config` file, and paste this in, replacing `<YOUR-AWS-USERNAME>` in the three places it appears:

```
[profile teaching-vacancies]
mfa_serial=arn:aws:iam::530003481352:mfa/<YOUR-AWS-USERNAME>
region=eu-west-2

[profile ReadOnly]
mfa_serial=arn:aws:iam::530003481352:mfa/<YOUR-AWS-USERNAME>
region=eu-west-2
role_arn=arn:aws:iam::530003481352:role/ReadOnly
source_profile=teaching-vacancies

[profile SecretEditor]
mfa_serial=arn:aws:iam::530003481352:mfa/<YOUR-AWS-USERNAME>
region=eu-west-2
role_arn=arn:aws:iam::530003481352:role/SecretEditor
source_profile=teaching-vacancies
```

If needed, two other profiles can also be included for the Deployments and Administrator roles. 

```
[profile Deployments]
mfa_serial=arn:aws:iam::530003481352:mfa/<YOUR-AWS-USERNAME>
region=eu-west-2
role_arn=arn:aws:iam::530003481352:role/Deployments
source_profile=teaching-vacancies

[profile Administrator]
mfa_serial=arn:aws:iam::530003481352:mfa/<YOUR-AWS-USERNAME>
region=eu-west-2
role_arn=arn:aws:iam::530003481352:role/Administrator
source_profile=teaching-vacancies
```

Then use AWS Vault to set the credentials:
```bash
aws-vault add teaching-vacancies
```

You'll be prompted to enter ID of an Access Key you created [here](https://console.aws.amazon.com/iam/home?region=eu-west-2#/security_credentials), and the key itself, which you saw when you created it:
```
Enter Access Key ID:
Enter Secret Access Key:
```
Then you will see:
```
Added credentials to profile "teaching-vacancies" in vault
```

## Log in to the AWS Console with AWS Vault

Log in and switch to the `ReadOnly` role:
```bash
aws-vault login ReadOnly
```

You should be prompted for an MFA code:
```
Enter token for arn:aws:iam::530003481352:mfa/<YOUR-AWS-USERNAME>:
```

You should see a link with a very long `SigninToken`

```
https://signin.aws.amazon.com/federation?Action=login&Issuer=aws-vault&Destination=https%3A%2F%2Fconsole.aws.amazon.com%2F&SigninToken=CfTUyKvXf1Xq3qjTRUNCATED
```

## Work with the AWS CLI on the command line

Refresh the `.env` file
```bash
aws-vault exec ReadOnly -- make -s local print-env > .env
```

List the S3 buckets
```bash
aws-vault exec ReadOnly -- aws s3 ls
```

## Rotate AWS credentials for AWS Vault

[Rotate your AWS access keys](https://github.com/99designs/aws-vault/blob/master/USAGE.md#rotating-credentials) at least every 90 days with this command:

```bash
aws-vault rotate teaching-vacancies
```

## Use the AWS CLI without AWS Vault

In this example you will use your personal Access Key and Secret key in the `[teaching-vacancies]` profile

If for any reason you had issues with the AWS Vault tool, you could use the AWS CLI directly by:

```bash
aws configure --profile teaching-vacancies
```

You'll be prompted:
```
AWS Access Key ID [None]: AKIA
AWS Secret Access Key [None]: GXdB
Default region name [eu-west-2]:
Default output format [None]:
```

And then running e.g.
```bash
aws s3 ls --profile ReadOnly
```

## Assuming an AWS role without AWS Vault

In this example you will use your personal Access Key and Secret key in the `[default]` profile, and are able to use third-party tools which do not understand the AWS `--profile` option, such as Terraform.


```bash
aws configure
```

You'll be prompted:
```
AWS Access Key ID [None]: AKIA
AWS Secret Access Key [None]: GXdB
Default region name [eu-west-2]:
Default output format [None]:
```

There is a useful [Gruntwork](https://blog.gruntwork.io/authenticating-to-aws-with-environment-variables-e793d6f6d02e) blog

Generate an MFA token in your Authenticator App, then use it in this command

```bash
aws sts get-session-token --serial-number arn:aws:iam::530003481352:mfa/<YOUR-AWS-USERNAME> --token-code <MFA-token>
```

```bash
aws sts assume-role \
  --role-arn arn:aws:iam::530003481352:role/ReadOnly \
  --role-session-name <YOUR-AWS-USERNAME> \
  --serial-number arn:aws:iam::530003481352:mfa/<YOUR-AWS-USERNAME> \
  --token-code <MFA-token>
```

You will see temporary session credentials, which have a duration of one hour
```
{
    "Credentials": {
        "AccessKeyId": "AKIAIOSFODNN7EXAMPLE",
        "SecretAccessKey": "wJalrXUtnFEMI/K7MDENG/bPxRfiCYzEXAMPLEKEY",
        "SessionToken": "AQoEXAMPLEH4aoAH0gNCAPyJxz4BlCFFxWNE1OPTgk5TthT+FvwqnKwRcOIfrRh3c/LTo6UDdyJwOOvEVPvLXCrrrUtdnniCEXAMPLE/IvU1dYUg2RVAJBanLiHb4IgRmpRV3zrkuWJOgQs8IZZaIv2BXIa2R4OlgkBN9bkUDNCJiBeb/AXlzBBko7b15fjrBs2+cTQtpZ3CYWFXG8C5zqx37wnOE49mRl/+OtkIKGO7fAE",
        "Expiration": "2021-03-16T19:23:20+00:00"
    },
    "AssumedRoleUser": {
        "AssumedRoleId": "AROAXWZVLKMEK2POASFO6:<YOUR-AWS-USERNAME>",
        "Arn": "arn:aws:sts::530003481352:assumed-role/ReadOnly/<YOUR-AWS-USERNAME>"
    }
}
```

Using the examples above, set these as environment variables:

```bash
export AWS_ACCESS_KEY_ID=AKIAIOSFODNN7EXAMPLE
export AWS_SECRET_ACCESS_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYzEXAMPLEKEY
export AWS_SESSION_TOKEN=AQoEXAMPLEH4aoAH0gNCAPyJxz4BlCFFxWNE1OPTgk5TthT+FvwqnKwRcOIfrRh3c/LTo6UDdyJwOOvEVPvLXCrrrUtdnniCEXAMPLE/IvU1dYUg2RVAJBanLiHb4IgRmpRV3zrkuWJOgQs8IZZaIv2BXIa2R4OlgkBN9bkUDNCJiBeb/AXlzBBko7b15fjrBs2+cTQtpZ3CYWFXG8C5zqx37wnOE49mRl/+OtkIKGO7fAE
```

It may be easier to copy and paste without the examples, like so:
```bash
export AWS_ACCESS_KEY_ID=
export AWS_SECRET_ACCESS_KEY=
export AWS_SESSION_TOKEN=
```

If you need to renew your session, you'll need to first unset the environment variables (starting a new terminal will usually have the same effect)

If generating these sessions is a regular activity, then you may find this snippet helpful. It uses `jq` to extract the three values, before setting them as environment variables:

```bash
sessionInfo="$(aws sts assume-role --role-arn arn:aws:iam::530003481352:role/ReadOnly --role-session-name <YOUR-AWS-USERNAME> --serial-number arn:aws:iam::530003481352:mfa/<YOUR-AWS-USERNAME> --token-code 123456)"
export AWS_ACCESS_KEY_ID="$(echo $sessionInfo | jq '.Credentials.AccessKeyId' | tr -d '"')"
export AWS_SECRET_ACCESS_KEY="$(echo $sessionInfo | jq '.Credentials.SecretAccessKey' | tr -d '"')"
export AWS_SESSION_TOKEN="$(echo $sessionInfo | jq '.Credentials.SessionToken' | tr -d '"')"
```


### Rotating `deploy` user access key


The `deploy` user is an AWS account and it is used to run the CI/CD. Both its `access key` and `access_key_id` are stored on Github Secrets (AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY). For security reasons, the access key needs to be rotated occasionally e.g. every 3 months

The `deploy` user and its access key (` aws_iam_access_key` ) are deployed via the `common` terraform module. Please note, these resources are not deployed via the CI\CD pipeline.

To rotate the key, please do the following:-
- [] From the root of the project, change directory - `cd terraform/common/`
- [] `aws-vault exec Administrator -- terraform apply -replace aws_iam_access_key.deploy`
- [] `aws-vault exec Administrator -- terraform output -json` - note the newly generated ACCESS_KEY_ID and ACCESS_KEY.
- [] Copy the newly generated ACCESS_KEY_ID and ACCESS_KEY to Github secrets -  AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY.
- [] Test by running/triggering a deploy workflow or run a workflow_dispatch action
