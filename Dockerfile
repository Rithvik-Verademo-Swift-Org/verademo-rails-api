FROM ruby:4.0.5

WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .

RUN mkdir -p certs && openssl req -x509 -newkey rsa:2048 -nodes -keyout certs/key.pem -out certs/cert.pem -days 365 -subj "/CN=localhost"
    
EXPOSE 3000 443

CMD ["sh", "-c", "bin/rails db:migrate && bundle exec rails server"]
