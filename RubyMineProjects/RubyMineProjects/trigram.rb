require 'uri'
require 'net/http'

def words text
  text.downcase.scan(/[a-z]+/)
end

url = "http://www.gutenberg.org/files/27520/27520-0.txt"
r = Net::HTTP.get_response(URI.parse(url).host, URI.parse(url).path)

puts url
#puts r.body.to_s
$words = words(r.body.to_s)

bi_grams = Hash.new(0)
tri_grams = Hash.new(0)

num = $words.length - 2
num.times {|i|
  bi = $words[i] + ' ' + $words[i+1]
  tri = bi + ' ' + $words[i+2]
  bi_grams[bi] += 1
  tri_grams[tri] += 1
}

puts "bi-grams:"
bb = bi_grams.sort{|a,b| b[1] <=> a[1]}
(num / 10).times {|i|  puts "#{bb[i][0]} : #{bb[i][1]}"}
puts "tri-grams:"
tt = tri_grams.sort{|a,b| b[1] <=> a[1]}
(num / 10).times {|i|  puts "#{tt[i][0]} : #{tt[i][1]}"}
