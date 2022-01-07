# Previewing emails

![screenshot of a mailer preview](https://user-images.githubusercontent.com/60350599/109692100-054e9b00-7b80-11eb-8568-34d6817d7ad8.png)

During development, you can quickly check the format/text of an email, and easily permute the data which the email presents, by using Rails' [mailer previews](https://edgeguides.rubyonrails.org/action_mailer_basics.html#previewing-emails).

The preview files have been written to rely either on your existing records, or records from the seed data (`seeds.rb`), so that you do not clutter your development database with new factory-created records every time you view the preview.

### View the previews

Visit http://localhost:3000/rails/mailers.

### Edit the preview files

Go to `spec/mailers/previews`.
