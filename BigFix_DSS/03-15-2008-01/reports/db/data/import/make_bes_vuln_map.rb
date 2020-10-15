require 'yaml'
require '../fake/lib/db_importer'

fixlets = YAML::load(STDIN)
vulns = Vuln.find(:all, :include => :vuln_advisories)
cve_to_vuln = vulns.index_by &:cve

map = []

fixlets['fixlets'].each do |fixlet|
  cve_list = fixlet['cve'].split(/; */)
  cve_list.each do |cve|
    vuln = cve_to_vuln[cve]
    if vuln
      #puts "Found vuln #{vuln.id}: #{vuln.name} for #{cve}."
      local_site = BESSite.find_by_url(fixlet['site_url']) || BESSite.create!(:url => fixlet['site_url'])
      map << [vuln.id, fixlet['fixlet_id'], local_site.id]
    #else
    #  puts "No vuln for #{cve}"
    end
  end
end
map.uniq!

class BESVulnWriter < DBImporter
  def initialize(outfile)
    super(outfile)
    add_table('vulns_bes', ['vuln_id', 'fixlet_id', 'bes_site_id'])
  end
  
  def write_map(fixlet_map)
    fixlet_map.each do |rec|
      add_record('vulns_bes', rec)
    end
  end
end

imp = BESVulnWriter.new(STDOUT)
imp.write_map(map)
imp.flush
