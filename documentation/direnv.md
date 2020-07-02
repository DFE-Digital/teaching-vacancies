## direnv

We recommend using something like [`direnv`](https://direnv.net/) to automatically load environment variables scoped into the folder.

Once direnv is installed, you should:

* [Hook it into your shell](https://direnv.net/docs/hook.html) (remembering to reload the shell profile with e.g. `source ~/.zshrc`)

* Tell direnv to look in your `.env` file by creating a `.envrc` file containing only the word `dotenv`.

* Allow direnv access to your current directory:

```bash
direnv allow .
```
