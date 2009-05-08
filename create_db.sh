#!/bin/sh

sqlite3 murlshtest.db <<EOS
CREATE TABLE url (
  id INTEGER PRIMARY KEY,
  time TIMESTAMP,
  url TEXT,
  email TEXT,
  name TEXT,
  title TEXT);
EOS
