cfg = 'qabes'

c = ActiveRecord::Base.sqlserver_connection(ActiveRecord::Base.configurations['qabes'])

rows = c.select_all("SELECT sitenamemap.siteurl, id, name, dbo.fn_ExtractField('MIME_X-Fixlet-CVE', 1, fields) AS cve FROM external_object_defs INNER JOIN sitenamemap ON (external_object_defs.sitename = sitenamemap.sitename) WHERE dbo.fn_ExtractField('MIME_X-Fixlet-CVE', 1, fields) IS NOT NULL AND dbo.fn_ExtractField('MIME_X-Fixlet-CVE', 1, fields) <> 'N/A'")

# Output in YAML form

fixlets = []
rows.each do |row|
  fixlets << { 'site_url' => row['siteurl'],
               'fixlet_id' => row['id'],
               'cve' => row['cve'] }
end

puts({ 'fixlets' => fixlets }.to_yaml)
