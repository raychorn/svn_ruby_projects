require 'uuidtools'

class UserTempTable < ActiveRecord::Base
	belongs_to :user
	serialize :table_arguments

	def initialize(*rest)
		super
		self.table_name = 'utt_' + UUID.random_create.to_s.underscore if self.table_name.empty?
	end

	def before_destroy
		self.connection.execute("drop table if exists `#{self.table_name}`")
	end
end
