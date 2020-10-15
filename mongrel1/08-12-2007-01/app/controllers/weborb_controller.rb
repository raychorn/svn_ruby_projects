require 'weborb/util'
require 'weborb/formats/parser_factory'
require 'weborb/dispatcher/weborb_dispatcher'
require 'weborb/writer/response_writer'
require 'weborb/config/weborb_config'
require 'weborb/log'
require 'weborb/context'
require 'helpers/flex_only_classes'
require 'all_property'
begin
  require 'weborb_amf3_hook'
rescue LoadError
end

class WeborbController < ApplicationController
	def getFilePath(name)
		dirName = 'public/weborb/'
		ar = dirName.split("/")
		fDir = ""
		ar.each{ |each| 
			fDir += each
			begin
				Dir.mkdir(fDir)
			rescue
			end
			fDir += "/"
		}
		dirName + name
	end
	
	def getFileNameByPrefixAndNum(prefix,num)
		getFilePath(prefix) + num.to_s + ".txt"
	end
    
	def getFileNameByNum(num)
        getFileNameByPrefixAndNum("file",num)
	end
    
	def nextFileName
		for i in 0...1000 do
			fname = getFileNameByNum(i)
			break if !File.exist?(fname)
		end
        @num = i
		fname
	end
	
	def readBinaryFile(num)
        fname = getFileNameByNum(num)
        fhand = File.new(fname, "rb")
        binary_s = fhand.gets
        fhand.close
        binary_s
    end
    
	def analyzeAckFiles(num)
        prev_s = ""
        j = 0
        @ackAnalysis = Array.new
		for i in 0...num do
            bin_s = readBinaryFile(j)
            if (prev_s.length > 0)
                @ackAnalysis.push((prev_s == bin_s))
                break if !@ackAnalysis[@ackAnalysis.length - 1]
            end
            prev_s = bin_s
            j += 2
        end
	end

    private :nextFileName, :getFilePath, :getFileNameByNum, :getFileNameByPrefixAndNum, :analyzeAckFiles, :readBinaryFile
	
	def index
		input = Array.new
		request.raw_post.each_byte {|byte| input.push byte }

		if Log.debug?
			Log.debug( "processing request: " + request.raw_post )
		end

		p = request.request_parameters
		isFast = false
		isDebug = false
		isDebugVerbose = false
        isDebugAnalysis = false
		begin
			isFast = (p["isfast"] == "true")
			isDebug = (p["isdebug"] == "true")
			isDebugVerbose = (p["isdebugverbose"] == "true")
	        isDebugAnalysis = (p["isdebuganalysis"] == "true")
        rescue
		end
		RequestContext.set_context( request, session )
		parser = ParserFactory.getParser
		request_message = parser.read_message( input, isFast)
		success = WebOrbDispatcher.dispatch request_message

		formatter = request_message.formatter
		
		ResponseWriter.write( request_message, formatter );
		bytes = formatter.get_bytes
		formatter.cleanup

		binary_string = ""
		if (bytes.class.to_s == "String") then
			binary_string = bytes
		else
			bytes.each {|byte| binary_string << byte.chr }
		end

		if Log.info?
			Log.info( "returning response, length: " + bytes.length.to_s )
		end

        if isDebug
            fname = nextFileName
            fhand = File.new(fname, (isDebugVerbose ? "w" : "wb"))
            if isDebugVerbose
		        i = -1
		        binary_string.each {|b| fhand.puts "[" + (i += 1).to_s + "]" + b.to_s + "\n" }
            else
                fhand.puts binary_string
            end
            fhand.close
   
           if isDebugAnalysis
               n = @num - 2
               if n >= 0
                    isAck = ((@num + 1) % 2) == 1
                    binary_string0 = readBinaryFile(@num)
                    binary_string1 = readBinaryFile(n)
                    isEqual = (binary_string0 == binary_string1)
                    analysis = "isAck=" + isAck.to_s + ", Compare @num=" + @num.to_s + " to n=" + n.to_s + ", isEqual=" + isEqual.to_s + "\n"
                    puts analysis
                    fname = getFileNameByPrefixAndNum("Analysis",0)
                    fhand = File.new(fname, "a")
                    fhand.puts analysis
                    analyzeAckFiles((@num + 1) / 2)
                    fhand.puts @ackAnalysis.inspect + "\n"
                    fhand.close
                end
            end
        end
			
		response.headers["Content-Type"] = "application/x-amf"
		render :text => binary_string
	end
end
