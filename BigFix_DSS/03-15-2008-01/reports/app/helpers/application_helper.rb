# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
    class DirUtils < Dir
        def DirUtils::mkdir!(path)
	        ar = path.split("/")
	        fDir = ""
	        ar.each{ |each| 
		        fDir += each
		        begin
                    if (fDir.include?(".") == false) then Dir.mkdir(fDir) end
		        rescue
		        end
		        fDir += "/"
	        }
            path
        end
    end
end
