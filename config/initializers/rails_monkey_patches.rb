class ActiveRecord::ConnectionAdapters::PostgreSQLAdapter
  # partition triggers can't return values. :(
  def supports_insert_with_returning?
    false
  end
end
