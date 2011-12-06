# == Schema Information
#
# Table name: sme_logs
#
#  created_at :datetime
#  event      :string(255)     not null
#  user_id    :integer
#  _data      :text
#
# Indexes
#
#  index_sme_logs_on_created_at         (created_at)
#  index_sme_logs_on_event_and_user_id  (event,user_id)
#

class Sme::Log < ActiveRecord::Base
  set_table_name  :sme_logs

  # Initialize an instance.
  #
  # Attributes in the underlying table are extracted and set individually.
  # +data+ is converted to json and stored in the +_data+ field.
  #
  def initialize(data)
    attributes = data.stringify_keys.slice(*self.class.column_names)
    attributes['event'] = attributes['event'].to_s if attributes['event']
    super(attributes.merge!('_data' => data.to_json))
  end

end
