# == Schema Information
#
# Table name: sme_rollups
#
#  id         :integer         not null, primary key
#  from       :datetime        not null
#  to         :datetime        not null
#  event      :string(255)     not null
#  value      :float
#  notes      :text
#  created_at :datetime
#  updated_at :datetime
#
# Indexes
#
#  index_sme_rollups_on_from_and_to_and_event  (from,to,event) UNIQUE
#

class Sme::Rollup < ActiveRecord::Base
  set_table_name :sme_rollups

end
