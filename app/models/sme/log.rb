# == Schema Information
#
# Table name: sme_logs
#
#  created_at :datetime
#  event      :string(255)     not null
#  user_id    :integer
#  notes      :text
#
# Indexes
#
#  index_sme_logs_on_created_at         (created_at)
#  index_sme_logs_on_event_and_user_id  (event,user_id)
#

class Sme::Log < ActiveRecord::Base
  set_table_name  :sme_logs
end
