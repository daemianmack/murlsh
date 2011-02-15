require 'murlsh'

module Murlsh

  module_function

  # Sort a hash by key and write it to a file as YAML.
  def write_ordered_hash(h, path)
    h.extend(Murlsh::YamlOrderedHash)
    h.each_value do |v|
      v.extend(Murlsh::YamlOrderedHash)  if v.is_a?(Hash)
    end

    open(path, 'w') { |f| YAML.dump(h, f) }
  end

end
