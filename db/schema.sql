CREATE DATABASE axehunter

\c axehunter

CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  email TEXT,
  password_digest TEXT
);

CREATE TABLE reviews (
  id SERIAL PRIMARY KEY,
  model text,
  rating integer,
  img_name text,
  img_url text,
  review varchar(800),
  user_id integer,
  user_email text
);

