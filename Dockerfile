FROM ruby:2.4.1
MAINTAINER Oleksandr Lapchenko <ozeron@me.com>

RUN mkdir /app
WORKDIR /app

COPY Gemfile Gemfile.lock /app/
RUN bundle install

# Set environment variables.
ENV PORT 8080

COPY . /app

# Define default command.
RUN ["/bin/bash"]
# Expose ports.
EXPOSE $PORT
