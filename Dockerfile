FROM dfedigital/teaching-vacancies:builder AS builder
FROM dfedigital/teaching-vacancies:final
USER app
CMD bundle exec rails db:migrate && bundle exec rails s
