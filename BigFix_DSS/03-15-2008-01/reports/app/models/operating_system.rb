require 'editor_support'
class OperatingSystem < ActiveRecord::Base
	acts_as_tree
	editable

	def descendants
		# This will loop infinitely if there is a cycle in the tree!
		children + children.dup.map { |c| c.descendants }.flatten
	end
end
