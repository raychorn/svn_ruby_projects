class CreateEmployees < ActiveRecord::Migration
  def self.up
    create_table :employees do |t|
       t.column :name, :string
       t.column :hiredate, :date
       t.column :salary, :float
       t.column :fulltime, :boolean
       t.column :vacationdays, :integer
       t.column :comments, :text

      t.timestamps
    end
  end

  def self.down
    drop_table :employees
  end
end
