require 'weborb/context'
require 'weborb/log'

class BenchmarkTest
    def random_password(size = 8)
        chars = (('a'..'z').to_a + ('0'..'9').to_a) - %w(i o 0 1 l 0)
        (1..size).collect{|a| chars[rand(chars.size)] }.join
        end

    def getData1(args)
        testMethod = args[0]
		data = Array.new
		for i in 0...10000 do
			data.push(Fixnum.induced_from(rand(65535)))
		end
        data.insert(0, testMethod)
		data
	end

    def getData1a(args)
        testMethod = args[0]
		data = Hash.new
		for i in 0...10000 do
			data[i] = Fixnum.induced_from(rand(65535))
		end
        data["method"] = testMethod
		data
	end
	
	def getData2(args)
        testMethod = args[0]
		data = Array.new
		for i in 0...10000 do
			data.push(random_password(rand(32)))
		end
        data.insert(0, testMethod)
		data
	end

	def getData3(args)
        testMethod = args[0]
		data = Array.new
		for i in 0...10000 do
			data.push(rand(2147483648))
		end
        data.insert(0, testMethod)
		data
	end

	def getData4(args)
        testMethod = args[0]
		data = Array.new
		for i in 0...10000 do
			data.push(rand(256**20))
		end
        data.insert(0, testMethod)
		data
	end
end