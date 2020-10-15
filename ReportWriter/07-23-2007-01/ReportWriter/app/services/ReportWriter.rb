require 'weborb/context'
require 'rbconfig'
require 'helpers/flex_only_classes'

class ReportWriter
    def saveImage(args)
        puts "args=" + args.inspect
    end
    
    def deleteImage(args)
        result = WebOrbResult.new
        result.status = -1
        result.statusMsg = "Unable to delete the file"  
        if args.class.to_s == "Array"
            url = args[0]
            fname = "public/" + url
            result.statusMsg += " named " + fname
            bool = File.exists? fname
            if bool
                result.status = 1
                result.statusMsg = ""
                File.delete fname
            end
        end
        result
	end
	
    def saveReport(aReport)
        result = WebOrbResult.new
        result.status = 0  
        result.statusMsg = ""  
        result
    end
end