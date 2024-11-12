# syntax=docker/dockerfile:1

# Use the Ruby version you need
ARG RUBY_VERSION=3.3.5
FROM docker.io/library/ruby:$RUBY_VERSION-slim AS base

# Rails app lives here
WORKDIR /rails

# Install base packages
RUN apt-get update -qq && \
   apt-get install --no-install-recommends -y curl libjemalloc2 libvips postgresql-client && \
   rm -rf /var/lib/apt/lists /var/cache/apt/archives
    
  
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    build-essential \
    libpq-dev \
    libssl-dev \
    zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*
  
  # Install dependencies required for gem installations and native extensions
# RUN apt-get update -qq && apt-get install -y \
#   build-essential \
#   libpq-dev \
#   libsqlite3-dev \
#   libssl-dev \
#   libreadline-dev \
#   zlib1g-dev \
#   libyaml-dev \
#   libffi-dev \
#   libgmp-dev \
#   && rm -rf /var/lib/apt/lists/*
#  RUN rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Set development environment
ENV RAILS_ENV="development" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="production"

ENV LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

# Throw-away build stage to reduce size of final image
FROM base AS build


# Install application gems
COPY Gemfile Gemfile.lock ./
# RUN gem install bundler -v '2.5.22' && bundle _2.5.22_ install
# RUN bundle install 
RUN gem install bundler -v '2.5.22'
# RUN gem install debase -v '0.2.6'
# RUN gem install ruby-debug-ide -v '0.7.3'
RUN bundle install 

RUN echo "alias rails='./bin/rails'" >> ~/.bashrc

# Copy application code
COPY . .

# Final stage for app image
FROM base

# Copy built artifacts: gems, application
COPY --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --from=build /rails /rails

# Run and own only the runtime files as a non-root user for security
RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash && \
    chown -R rails:rails db log storage tmp
USER 1000:1000

# Start the server by default
EXPOSE 3000
CMD ["./bin/rails", "server", "-b", "0.0.0.0"]
