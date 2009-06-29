require 'rubygems'
require 'bcrypt'

require 'csv'
require 'digest/md5'

module Murlsh

  class Auth

    def initialize(file)
      @file = file
    end

    def auth(password)
      CSV::Reader.parse(open(@file)) do |row|
        return { :name => row[0], :email => row[1] } if
          BCrypt::Password.new(row[2]) == password
      end
    end

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
