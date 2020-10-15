#!/usr/bin/env ruby

srand Time.now.to_i

propernames = File.new('/usr/share/dict/propernames').readlines.map &:chomp
names = (0..250).map { "#{propernames[rand(propernames.length)]} #{propernames[rand(propernames.length)]}" }
names.each { |n| Contact.new(:vcard => Vpim::Vcard::Maker.make2 { |m| m.name { |name| name.given, name.family = n.split }; m.add_email(n.downcase.gsub(' ', '_') + "@example.com"); m.add_tel("(%03d)%03d-%04d" % [200+rand(800), 200 + rand(800), rand(10000)]) { |t| t.location = 'work' } }.to_s).save! }
