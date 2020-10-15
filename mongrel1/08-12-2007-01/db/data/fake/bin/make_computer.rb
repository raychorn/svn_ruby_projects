require 'lib/computer_generator'

ipaddr = '10.1.1.1'
nbname = 'HOST'

comp_defs = ComputerDefs.new(ARGV[0])
gen = ComputerGenerator.new(comp_defs)
base = { 'ip_address' => ipaddr,
         'netbios_name' => nbname }
comp = gen.generate(base, ARGV[1..-1], :target_cvss_score => 15.0)

puts comp.inspect
puts comp.aggregate_cvss_score(comp_defs)
