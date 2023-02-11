# syntax=docker/dockerfile:1

ARG ALPINE_RUBY_VERSION=3.2

FROM ruby:${ALPINE_RUBY_VERSION}-alpine

ARG RAILS_VERSION=rails_7_0
ARG RSPEC_VERSION=rspec_gte_3_10

WORKDIR /opt/super_diff

ENV BUNDLE_PATH=vendor/bundle
ENV BUNDLE_CACHE_PATH=vendor/cache
ENV GEMFILE_PATH=gemfiles/${RAILS_VERSION}_${RSPEC_VERSION}.gemfile

# Install dependencies
RUN apk add --update --no-cache \
  bash \
  #binutils-gold \
  #build-base \
  #curl \
  git \
  #libc6-compat \
  #make \
  nodejs \
  #openssl-dev \
  #tzdata \
  #yarn
RUN npm install -g yarn
RUN gem install bundler

COPY .yarn .
COPY .yarnrc.yml .
COPY package.json .
RUN yarn install

COPY gemfiles/${RAILS_VERSION}_${RSPEC_VERSION}.gemfile gemfiles
RUN mkdir -p vendor
RUN bundle install --jobs 4

COPY .
