function log() {
  echo -e "\n$(tput setaf 4)++ $(tput bold)$1$(tput sgr0)"
}

# Get barebones bashrc sourced
if ! grep teaching_vacancies_bashrc /etc/bash.bashrc; then
  log 'Adding sourcing of barebones bashrc to /etc/bash.bashrc'

  echo -e "\nsource /app/.devcontainer/teaching_vacancies_bashrc.sh" | sudo tee -a /etc/bash.bashrc
fi

log 'Ensure directories mounted via Docker volumes are owned by non-privileged user'
sudo chown $(id -u):$(id -g) /app/node_modules /app/public/packs /app/tmp

log 'Ensure Bundler directory is owned by `bundler` group and has group write permissions'
sudo chgrp -R bundler /usr/local/bundle
sudo chmod -R g+w /usr/local/bundle

log 'Install Ruby dependencies'
bundle install

log 'Install Javascript dependencies'
yarn install

log 'Ensure `tmp` folder has a `.keep` file'
# (this is present on the host, but the container uses a volume for the `tmp` directory,
# leading Git to believe the `.keep` file has gone missing)
touch /app/tmp/.keep

log 'Allow using `psql` without needing to enter a password'
echo "db:5432:*:postgres:postgres" > $HOME/.pgpass
chmod 600 $HOME/.pgpass

log 'Create test database'
RAILS_ENV=test bundle exec rails db:create

log 'Run `rails db:prepare`'
bundle exec rails db:prepare

echo
echo -e "┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓"
echo -e "┃ 🏫$(tput bold) Welcome to Teaching Vacancies! $(tput sgr0)                   ┃"
echo -e "┃                                                      ┃"
echo -e "┃ Your devcontainer is now ready to go and you can     ┃"
echo -e "┃ close this terminal window. If you need any help or  ┃"
echo -e "┃ more information, check out:                         ┃"
echo -e "┃ documentation/devcontainer.md                        ┃"
echo -e "┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛"
