#!/usr/bin/ruby

class AppStore
  def initialize
    @apps = App.find_all_applications
  end
  
  def getRandomAppVersion
    app = getRandomApp
    versions = app.versions
    return app if versions.empty?
    versions[rand(versions.length)]
  end
  
  def getRandomApp
    @apps[rand(@apps.length)]
  end
end

class FakeHostFactory
  def initialize
    @apps = AppStore.new
    @vulns = Vuln.find_all
  end
  
  def make(properties)
    host = { 'properties' => properties }
    
    apps = pickRandomApps(0, 15)
    vulns = pickRandomVulns(1, 3)
    apps.concat(vulns.map(&:apps).flatten)
    host['apps'] = apps.map { |app| { 'id' => app.id, 'name' => app.name } }
    host['vulns'] = vulns.map { |vuln| { 'id' => vuln.id, 'name' => vuln.name } }

    host
  end
  
  def pickRandomApps(min, max)
    count = rand(max - min + 1) + min
    
    apps = []
    
    count.times do
      apps << @apps.getRandomAppVersion
    end
    
    apps
  end
  
  def pickRandomVulns(min, max)
    count = rand(max - min + 1) + min
    
    vulns = []
    
    count.times do
      vulns << @vulns[rand(@vulns.length)]
    end
    
    vulns
  end
  
  def pickRandomVulnsForApps(apps, min, max)
    vulns = []
    
    apps.each do |app|
      count = rand(max + 1) - min
      
      next unless count > 0
      
      app_vulns = app.vulns
      
      count.times do
        break if app_vulns.empty?
        
        vulns << app_vulns.delete_at(rand(vulns.length))        
      end
    end
    
    vulns
  end  
end

# Initialize PRNG
srand(Time.new.to_i)

factory = FakeHostFactory.new

props = { 'IP Address' => '10.1.1.1', 
          'DNS' => 'fake.host.example.com',
          'NetBIOS Name' => 'FAKEHOST' }

print factory.make(props).to_yaml