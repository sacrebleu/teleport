FROM ruby:2.5.1-stretch
MAINTAINER Jeremy Botha

# add marionette user
RUN useradd -ms /bin/bash teleport

RUN apt-get update
RUN apt-get install -y nodejs

RUN gem install bundler

USER teleport
WORKDIR /home/teleport

COPY Gemfile Gemfile.lock ./
RUN bundle install --jobs 20 --retry 5 --deployment

COPY --chown=teleport:teleport . ./

ENV RAILS_ENV production

# RUN RAILS_ENV=production bundle exec rake db:migrate

EXPOSE 3000
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]