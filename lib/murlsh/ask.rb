module Murlsh

  module_function

  # Ask the user a question and return the answer.
  def ask(prompt, default)
    print "#{prompt} [#{default}] "
    answer = $stdin.gets.strip
    answer = default  if answer.empty?
    answer
  end

end
