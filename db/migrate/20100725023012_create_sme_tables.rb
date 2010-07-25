class CreateSmeTables < ActiveRecord::Migration
  def self.up
    create_table :sme_logs, :id => false do |t|
      t.timestamp :created_at
      t.string    :event,      :null => false
      t.integer   :user_id
      t.text      :notes
    end

    add_index :sme_logs, :created_at
    add_index :sme_logs, [:event, :user_id]

    if 'postgresql' == ActiveRecord::Base.configurations[RAILS_ENV]['adapter']
      SE::Partition.partition(Sme::Log, :created_at, :verbose => false)
    end

    create_table :sme_rollups do |t|
      t.timestamp :from,  :null => false
      t.timestamp :to,    :null => false
      t.string    :event, :null => false
      t.float     :value
      t.text      :notes
      t.timestamps
    end

    add_index :sme_rollups, [:from, :to, :event], :unique => true
  end

  def self.down
    drop_table :sme_logs
    drop_table :sme_rollups
  end
end
