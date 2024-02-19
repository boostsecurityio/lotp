FROM ruby:3.2@sha256:93c3c0d55a9bba1c853c86f3f3eb38b1eaec8b4fe89d491a9fe5d125eeaed4c7

WORKDIR /app

COPY Gemfile Gemfile.lock ./

RUN bundle install

CMD jekyll serve -H 0.0.0.0
