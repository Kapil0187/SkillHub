# backend/Dockerfile
FROM ruby:3.4.4

WORKDIR /app

# Install dependencies
RUN apt-get update -qq && apt-get install -y postgresql-client

# Copy Gemfiles and install gems
COPY Gemfile Gemfile.lock ./

RUN bundle install

# Copy application code
COPY . .

# Remove old Rails PID if it exists
RUN rm -f tmp/pids/server.pid

# Expose port 3000 for Rails
EXPOSE 3000

# Start Rails server
CMD ["bash", "-c", "bundle exec rails db:create db:migrate && bundle exec rails s -b 0.0.0.0"]
