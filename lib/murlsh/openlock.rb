module Murlsh

  module_function

  # Open a file with an exclusive lock.
  def openlock(*args)
    open(*args) do |f|
      f.flock(File::LOCK_EX) ; yield f ; f.flock(File::LOCK_UN)
    end
  end

end
