require 'weborb/context'
require 'weborb/log'
require 'rbconfig'
require 'set'
require 'helpers/flex_only_classes'

class ReportWriter
	def getFileName(name, userName)
		dirName = 'public/uploads/export/' + userName
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
		fName = dirName + '/' + name
	end
	private :getFileName
    def deleteImage(args)
        result = WebOrbResult.new
        result.status = -1
        result.info = "ReportWriter::deleteImage"
        result.statusMsg = "Unable to delete the file"  
        if args.class.to_s == "Array"
            url = args[0]
            fname = "public/" + url
            result.statusMsg += " named " + fname
            bool = File.exists? fname
            if bool
                result.status = 1
                result.statusMsg = ""
                #File.delete fname  #Cannot delete the images because we are not checking to see which report elements in the database may reference the image...
            end
        end
        result
	end
	
    def deleteReport(args)
        result = WebOrbResult.new
        result.info = "ReportWriter::deleteReport"
        result.status = -1
        result.statusMsg = "Invalid args sent to deleteReport !"  
        if (args.class.to_s == "Array") && (args.length == 1)
            result.status = 0
            result.statusMsg = ""  

            #puts "\nBEGIN:\n" + "=" * 20 + "\n"
            report = args[0]
            report.destroy
            #puts "report=" + report.inspect + "\n"
            #puts "=" * 20 + "\nEND!" + "\n\n"
            
        end
            
        result
	end
	
    def saveImage(args)
        result = WebOrbResult.new
        result.info = "ReportWriter::saveImage"
        result.status = -1
        result.statusMsg = "Invalid args sent to saveImage !"  
        if (args.class.to_s == "Array") && (args.length == 3)
            result.status = 0
            result.statusMsg = ""  
			
            #puts "\nBEGIN:\n" + "=" * 20 + "\n"
            name = args[0]
			username = args[1]
            serverFileName = getFileName(name, ((username.length > 0) ? username : "joeUser"))
			bytes = args[2]
            #puts "name=" + name + "\n"
            #puts "serverFileName=" + serverFileName + "\n"
            #puts "userName=" + username + "\n"
            #puts "bytes.class=" + bytes.class.to_s + "\n"
            #puts "bytes.length=" + bytes.length.to_s + "\n"
            #puts "bytes=" + bytes.inspect + "\n"

            fhand = File.new(serverFileName, "wb")
            #puts "fhand.class=" + fhand.class.to_s + "\n"
			bytes.each {|x| fhand.putc(x) }
			#fhand.flush
            fhand.close
			
            result.info += "|" + serverFileName
            #puts "=" * 20 + "\nEND!" + "\n\n"
		end
		
        result
	end
	
    def renameReport(args)
        result = WebOrbResult.new
        result.info = "ReportWriter::renameReport"
        result.status = -1
        result.statusMsg = "Invalid args sent to renameReport !"  
        if (args.class.to_s == "Array") && (args.length == 2)
            result.status = 0
            result.statusMsg = ""  
            
            #puts "\nBEGIN:\n" + "=" * 20 + "\n"

            report = args[1]
            newName = args[0]
            report.name = newName
            report.save!
            
            #puts "newName=" + newName + "\n"
            #puts "report=" + report.inspect + "\n"
            #puts "=" * 20 + "\nEND!" + "\n\n"
            
        end
        
        result
	end
	
    def checkReportName(args)
        result = WebOrbResult.new
        result.info = "ReportWriter::checkReportName"
        result.status = -1
        result.statusMsg = "Invalid args sent to checkReportName !"  
        if (args.class.to_s == "Array") && (args.length == 1)
            result.status = 0
            result.statusMsg = ""  
            
            name = args[0]
            reports = Report.find_all_by_name(name)
            if reports.empty? == false
                result.status = 1
            end
            #puts "\nBEGIN:\n" + "=" * 20 + "\n"
            #puts "name=" + name + "\n"
            #puts "reports=" + reports.inspect + "\n"
            #puts "result=" + result.inspect + "\n"
            #puts "=" * 20 + "\nEND!" + "\n\n"
            
        end
        
        result
	end
	
    def saveReport(args)
        result = WebOrbResult.new
        result.info = "ReportWriter::saveReport"
        if (args.class.to_s == "Array") && (args.length == 3)
            #puts "\nBEGIN:\n" + "=" * 20 + "\n"
            name = args[0]
            userID = args[1]
            data = args[2]
            #puts "name=" + name.to_s + "\n"
            #puts "userID=" + userID.to_s + "\n"
            data.each {|x| puts "=" * 20 + "\n" ; puts x.inspect + "\n" }
            #puts "=" * 20 + "\nEND!" + "\n\n"
            
            report = Report.new
            report.name = name
            report.user_id = userID
            report.data = data
            report.save!
            
            result.status = 0  
            result.statusMsg = ""  
        else
            result.status = -1  
            result.statusMsg = "Argument is not an Array. Cannot process the report."  
        end
        result
    end
end