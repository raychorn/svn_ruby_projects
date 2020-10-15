require 'rubygems'
gem 'imagesize'
require 'image_size'

class FileuploadController < ActionController::Base
	def getFileName(name, userName)
	   dirName = 'public/uploads/' + userName
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
	def index
		status = Hash.new
		status["upload"] = false
		status["success"] = false
		status["file"] = ""
		status["params"] = params
		#status["request"] = request.inspect
		fname = params["Filename"]
		status["file"] = fname
		status["serverFileName"] = ""
		if fname.nil? != true
			status["upload"] = true
			file = params["file"]
			serverFileName = getFileName(fname, "joeUser")
			status["serverFileName"] = serverFileName

            fhand = File.open(serverFileName, "wb")
            goop = file.binmode.read
            puts "goop=" + goop.length.to_s
            img = ImageSize.new(goop)
            fhand.write(goop)
            fhand.close
   
            iSize = img.get_type.to_s + "," + img.get_width.to_s + "," + img.get_height.to_s
			status["success"] = File.exists? serverFileName
            serverFileName += "|" + iSize
		end
		
		render :text => serverFileName
	end
end
