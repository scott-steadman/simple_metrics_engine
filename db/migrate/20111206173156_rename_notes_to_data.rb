class RenameNotesToData < ActiveRecord::Migration
  def self.up
    rename_column :sme_logs, :notes, :_data
  end

  def self.down
    rename_column :sme_logs, :_data, :notes
  end
end
