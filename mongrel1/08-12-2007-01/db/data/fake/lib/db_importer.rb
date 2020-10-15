class DBImporter
  def initialize(outfile)
    raise TypeError.new('Argument must be a file handle') unless outfile.respond_to? :write
    @outfile = outfile
    @records = {}
  end
  
  def add_table(table_name, colnames)
    @records[table_name] = { :rows => [], :colnames => colnames }
  end
  
  def add_record(table_name, row)
    @records[table_name][:rows] << row
    if @records[table_name][:rows].length > 1000
      flush_table(table_name)
    end
  end
  
  def flush
    @records.keys.each do |table_name|
      unless @records[table_name][:rows].empty?
        flush_table(table_name)
      end
    end
    @outfile.flush
  end
  
  def flush_table(table_name)
    @outfile.write("INSERT INTO #{table_name} (#{@records[table_name][:colnames].join(', ')}) VALUES")
    @first = true
    @records[table_name][:rows].each do |row|
      if @first
        @first = false
      else
        @outfile.write(",")
      end
      
      @outfile.write("(#{row.map { |v| quote(v) }.join(',')})")
    end
    
    @outfile.write(";\n")
    @records[table_name][:rows] = []
  end
  
  def quote(v)
    ActiveRecord::Base.connection.quote(v)
  end
  
  def self.import(*args)
    importer = self.new(*args)
    yield importer
    importer.flush
  end
end

class ComputerGroupDBImporter < DBImporter
  def initialize(outfile, start_date=nil)
    super(outfile)
    
    @start_date = start_date || Time.now
    @startID = ActiveRecord::Base.connection.select_value("SELECT max(id) FROM computer_groups").to_i + 1
    add_table('computer_groups', ['id', 'name', 'parent_id'])
    @id_map = {}
  end
  
  def write_groups(groups, parent_id=nil)
    groups.each do |key, group_def|
      group_id = @startID
      @startID += 1
      @id_map[key] = group_id
      add_record('computer_groups', [group_id, group_def['title'], parent_id])
      write_groups(group_def['subgroups'], group_id)
    end
  end
  
  def flush
    super
    returning @id_map do
      @id_map = {}
    end
  end
end

class ComputerDBImporter < DBImporter
  def initialize(outfile, collection, start_date=nil)
    super(outfile)
    @collection = collection
    @startID = ActiveRecord::Base.connection.select_value("SELECT max(id) FROM computers").to_i + 1
    @os_by_name = OperatingSystem.find(:all).index_by(&:name)
    
    @valid_from = (start_date || Time.now).to_s(:db)
    
    add_table('computers', ['id'])
    add_table('computer_groups_computers', ['computer_group_id', 'computer_id', 'valid_from', 'valid_to'])
    add_table('computer_properties',
              ['computer_id', 'property_id', 'value', 'valid_from', 'valid_to'])
    add_table('computer_apps', ['computer_id', 'app_id', 'port', 'valid_from', 'valid_to'])
    add_table('computer_vulns', ['computer_id', 'vuln_id', 'valid_from', 'valid_to'])
    add_table('computers_operating_systems',
              ['computer_id', 'operating_system_id', 'valid_from', 'valid_to'])
  end
  
  def write_computer(computer)
    id = @startID
    @startID += 1
    
    add_record('computers', [id])
    computer['groups'].each do |group_id, valid_from, valid_to|
      add_record('computer_groups_computers', [group_id, id, valid_from || @valid_from, valid_to])
    end if computer.has_key? 'groups'
    add_property(id, 1, computer['ip_address'])
    add_property(id, 2, computer['dns_name']) if computer['dns_name']
    add_property(id, 3, computer['netbios_name']) if computer['netbios_name']
    
    if os = @os_by_name[computer['os']]
      add_record('computers_operating_systems', [id, os.id, @valid_from, nil])
    else
      puts "! Unknown operating system #{computer['os'].inspect}"
    end

    add_apps(id, computer['applications'])
    add_vulns(id, computer['vulnerabilities'])
  end
  
  def add_property(computer_id, property_id, property_value, valid_from=@valid_from, valid_to=nil)
    add_record("computer_properties",
               [computer_id, property_id, property_value, valid_from, valid_to])
  end
  
  def add_apps(computer_id, apps)
    apps.each do |app, valid_from, valid_to|
      add_record("computer_apps", [computer_id, app.id, 0, valid_from || @valid_from, valid_to])
    end
  end
  
  def add_vulns(computer_id, vulns)
    vulns.each do |vuln, valid_from, valid_to|
      add_record("computer_vulns", [computer_id, vuln.id, valid_from || @valid_from, valid_to])
    end
  end
end
