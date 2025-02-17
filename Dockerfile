FROM ruby:3.3.5-slim

# Install git and build essentials
RUN apt-get update && \
    apt-get install -y \
    git \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /gem

# Copy only the files needed for bundle install
COPY Gemfile platform_client.gemspec ./
COPY lib/platform_client/version.rb lib/platform_client/

# Initialize git repo and install bundle
RUN git init && \
    bundle install

CMD ["tail", "-f", "/dev/null"]
