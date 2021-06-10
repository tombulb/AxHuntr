CREATE DATABASE axehunter

\c axehunter

CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  profile_name TEXT, 
  email TEXT,
  password_digest TEXT,
  dob TEXT,
  locale TEXT,
  gear TEXT,
  img_url TEXT
);

CREATE TABLE reviews (
  id SERIAL PRIMARY KEY,
  model text,
  rating integer,
  img_name text,
  img_url text,
  review varchar(1200),
  user_id integer,
  author text
);

