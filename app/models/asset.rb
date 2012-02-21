class Asset < ActiveRecord::Base
  acts_as_taggable
  
  validates_presence_of :name
end
