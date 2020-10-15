class CreateTasks < ActiveRecord::Migration
  def self.up
    create_table :tasks do |t|
      t.integer :user_id, :default => 0, :null => false
      t.integer :project_id
      t.integer :location_id
      t.string :name, :limit => 100, :default => "",
        :null => false
      t.text :notes
      t.boolean :next_action, :null => false, :default => false
      t.boolean :completed, :null => false, :default => false

      t.timestamps 
    end
  end

  def self.down
    drop_table :tasks
  end
end
