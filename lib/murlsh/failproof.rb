
module Murlsh

  module_function

  # Catch all exceptions unless options[:failproof] = false.
  def failproof(options={})
    begin
      yield
    rescue Exception
      raise unless options.fetch(:failproof, true)
    end
  end

end
