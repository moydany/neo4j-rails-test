FROM ruby:3.2.2 AS builder

RUN apt-get update -qq && apt-get install -y build-essential nodejs yarn

ENV INSTALL_PATH /metrics-api
RUN mkdir -p $INSTALL_PATH

WORKDIR $INSTALL_PATH

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .

RUN RAILS_ENV=development bundle exec rails assets:precompile

FROM builder

ENV NEO4J_URL="http://neo4j:password@neo4j-dev:7474"
ENV NEO4J_BOLT_URL="bolt://neo4j:password@neo4j-dev:7687"

CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]