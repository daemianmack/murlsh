#!/bin/sh

sqlite3 murlsh.db <<EOS
CREATE TABLE urls (
  id INTEGER PRIMARY KEY,
  time TIMESTAMP,
  url TEXT,
  email TEXT,
  name TEXT,
  title TEXT);
EOS
