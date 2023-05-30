# Stage 1: Building the application
FROM ruby:3.2.2 AS builder

# Install dependencies:
# - build-essential: To ensure certain gems can be compiled
# - nodejs: Compile assets
# - yarn: Manage JavaScript dependencies
RUN apt-get update -qq && apt-get install -y build-essential nodejs yarn

# Set an environment variable to store where the app is installed to inside
# of the Docker image.
ENV INSTALL_PATH /metrics-api
RUN mkdir -p $INSTALL_PATH

# This sets the context of where commands will be run and is documented
# on Docker's website extensively.
WORKDIR $INSTALL_PATH

# Ensure gems are cached and only get updated when they change. This will
# drastically increase build times when your gems do not change.
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Copy in the application code from your workstation at the current directory
# over to the working directory.
COPY . .

# Precompile Rails assets. Remove this line if you're not using Rails.
RUN RAILS_ENV=development bundle exec rails assets:precompile

# Stage 2: Running the application
FROM builder

# Set environment variables for Neo4j URL and Bolt URL
ENV NEO4J_URL="http://neo4j:password@neo4j-dev:7474"
ENV NEO4J_BOLT_URL="bolt://neo4j:password@neo4j-dev:7687"

# Run the rake command only during the first build

# The command to start the puma server.
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]