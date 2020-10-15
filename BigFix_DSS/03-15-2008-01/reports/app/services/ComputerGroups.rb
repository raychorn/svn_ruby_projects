require 'weborb/context'
require 'weborb/log'
require 'rbconfig'

class ComputerGroups
	def getTree()
		computer_groups = ComputerGroup.find_all_as_tree
		tree = []
		for computer_group in computer_groups
			followChildren(computer_group, tree)
		end
		tree
	end
	
	def create(group)
	  g = ComputerGroup.new
	  g.update_attributes(group.attributes)
	  g.save!
	  g
  end
	
	def update(group)
	  # XXX: Needs perms check
	  g = ComputerGroup.find(group.id)
	  g.update_attributes(group.attributes)
	  g.save!
	  g
  end
  
  def reparent(group, parent_id)
	  #XXX: Needs perms checks
    g = ComputerGroup.find(group.id)
    if parent_id != 0
      g.parent = ComputerGroup.find(parent_id)
    else
      g.parent_id = 0
    end
    g.save!
    g
  end
	
	def destroy(group)
	  #XXX: Needs perms check
	  ComputerGroup.find(group.id).destroy
	  nil
  end

	protected
	def followChildren(node, tree)
		tree << ComputerGroupTreeNode.new
		tree.last.id = node.id
		tree.last.name = node.name
		tree.last.children = [] unless node.children.empty?
		for child in node.children
			followChildren(child, tree.last.children)
		end
	end
end

