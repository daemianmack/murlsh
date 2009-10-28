require 'active_record/connection_adapters/sqlite3_adapter'

class ActiveRecord::ConnectionAdapters::SQLite3Adapter

  # Add MATCH function for regex matching.
  def initialize(connection, logger, config)
    super
    @connection.create_function('MATCH', 2) do |func,search_in,search_for|
      func.result = search_in.to_s.match(/#{search_for}/i) ? 1 : nil
    end
  end

end
