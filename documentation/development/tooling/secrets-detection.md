# Secrets detection

[Git secrets](https://github.com/awslabs/git-secrets) (not to be confused with [git-secret](https://git-secret.io/), nor with [GitHub Actions Encrypted Secrets](https://docs.github.com/en/actions/reference/encrypted-secrets)) acts as an extra line of defence to prevent you committing secrets. Once installed, it hooks into the `git commit` command.

From your `teaching-vacancies` repo, run:

```bash
brew install git-secrets
git secrets --install
git secrets --add '.+_PASSWORD\s*=\s*.+'
git secrets --add '.+_ID\s*=\s*.+'
git secrets --add '.+_KEY\s*=\s*.+'
git secrets --add '.+_SECRET\s*=\s*.+'
git secrets --add '.+_TOKEN\s*=\s*.+'
git secrets --add '.+_SALT\s*=\s*.+'
git secrets --add '.+_AUTHENTICATION\s*=\s*.+'
git secrets --add '.+_BASE\s*=\s*.+'
```

You should see these patterns added to the `.git/config` file.
