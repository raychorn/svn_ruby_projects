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
		fname = params["Filename"]
        username = params["username"]
        #puts "params=" + params.inspect + "\n"
        #puts "request=" + request.inspect + "\n"
		if fname.nil? != true
			file = params["file"]
            serverFileName = getFileName(fname, ((username.length > 0) ? username : "joeUser"))

            fhand = File.open(serverFileName, "wb")
            goop = file.binmode.read
            #puts "goop=" + goop.length.to_s + "\n"
            img = ImageSize.new(goop)
            fhand.write(goop)
            fhand.close
   
            iSize = img.get_type.to_s + "," + img.get_width.to_s + "," + img.get_height.to_s
            serverFileName += "|" + iSize
            #puts "serverFileName=" + serverFileName + "\n"
            end
		
		render :text => serverFileName
	end
end
