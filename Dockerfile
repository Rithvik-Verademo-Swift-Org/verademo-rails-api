FROM ruby:4.0.5

WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .

EXPOSE 3000

CMD ["sh", "-c", "bin/rails db:migrate && bundle exec rails server -b 0.0.0.0 -p 3000"]
