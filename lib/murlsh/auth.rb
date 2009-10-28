require 'rubygems'
require 'bcrypt'

require 'csv'
require 'digest/md5'

module Murlsh

  # Interface to authentication file. Format of authentication file:
  #
  # username,MD5 hash of email address,bcrypted password
  #
  # Authentication is done using password only to make adding easier and
  # because there will be a small number of trusted users.
  #
  # See Rakefile for user maintenance tasks.
  class Auth

    def initialize(file)
      @file = file
    end

    # Authenticate a user by password. Return their name and email if correct.
    def auth(password)
      CSV::Reader.parse(open(@file)) do |row|
        return { :name => row[0], :email => row[1] } if
          BCrypt::Password.new(row[2]) == password
      end
    end

    # Add a user to the authentication file.
    def add_user(username, email, password)
      open(@file, 'a') do |f|
        f.flock(File::LOCK_EX)
        f.write("#{[username, Digest::MD5.hexdigest(email),
          BCrypt::Password.create(password)].join(',')}\n")
        f.flock(File::LOCK_UN)
      end
    end

  end

end
