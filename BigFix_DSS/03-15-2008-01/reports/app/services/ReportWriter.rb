require 'weborb/context'
require 'weborb/log'
require 'rbconfig'
require 'set'
require_dependency 'flex_only_classes'

require 'rubygems'
gem 'pdf-writer'
require 'pdf/writer'

gem 'imagesize'
require 'image_size'

class ReportWriter
	def getFileName(name, userName)
          dirName = 'public/uploads/export/' + userName
          ApplicationHelper::DirUtils::mkdir!(dirName)
          fName = dirName + '/' + name
	end

	def removeExportFrom(folder)
        toks = folder.split("/")
        toks.delete("export")
        folder = toks.join("/")
        folder
    end
    
    def _getImages(userName, folder)
        begin
            ar = Dir.entries(folder)
        rescue
            ar = Array.new
        end
        ar.delete(".")
        ar.delete("..")
        ar
    end
    
    def _getImageSizeForNamedFile(fname)
        fhand = File.open(fname.to_s, "rb")
        img = ImageSize.new(fhand.binmode.read)
        fhand.close
        img
    end
    
    def _getImageSize(folder, fname)
        _getImageSizeForNamedFile(folder.to_s + "/" + fname.to_s)
    end
    
    private :getFileName, :_getImages, :removeExportFrom, :_getImageSize, :_getImageSizeForNamedFile
    
    def getImageCount(args)
        result = WebOrbResult.new
        result.info = "ReportWriter::getImageCount"
        result.status = -1
        result.statusMsg = "Invalid args sent to getImageCount !"  
        if (args.class.to_s == "Array") && (args.length == 1)
            result.status = 0
            result.statusMsg = ""  
            
            userName = args[0]
            ar = _getImages(userName, removeExportFrom(getFileName("", userName)))
            result.data = ar.length
        end
        
        result
    end
	
    def getAnImage(args)
        result = WebOrbResult.new
        result.info = "ReportWriter::getAnImage"
        result.status = -1
        result.statusMsg = "Invalid args sent to getAnImage !"  
        if (args.class.to_s == "Array") && ( (args.length == 2) || (args.length == 3) )
            result.status = 0
            result.statusMsg = ""  
            
            userName = args[0]
            num = args[1]
            cnt = 1
            cnt = args[2] if (args.length == 3)

            folder = removeExportFrom(getFileName("", userName))
            ar = _getImages(userName, folder)
            a = Array.new
            cnt.times {
                if num <= ar.length
                    aa = Array.new
                    fname = ar[num - 1]
                    aa.push(fname)
                    aa.push(_getImageSize(folder, fname).get_size)
                    a.push(aa)
                end
                num += 1
            }
            toks = folder.split("/")
            toks.delete("public")
            folder = toks.join("/")
            a.insert(0,folder)
            result.data = a
        end
        
        result
    end

    def getImages(args)
        result = WebOrbResult.new
        result.info = "ReportWriter::getImages"
        result.status = -1
        result.statusMsg = "Invalid args sent to getImages !"  
        if (args.class.to_s == "Array") && (args.length == 1)
            result.status = 0
            result.statusMsg = ""  
            
            userName = args[0]
            folder = removeExportFrom(getFileName("", userName))
            ar = _getImages(userName, folder)
            toks = folder.split("/")
            toks.delete("public")
            folder = toks.join("/")
            ar.insert(0,folder)
            result.data = ar
        end
        
        result
    end
	
    def validateImage(args)
        result = WebOrbResult.new
        result.status = -1
        result.info = "ReportWriter::validateImage"
        result.statusMsg = "Unable to validate the file."  
        if (args.class.to_s == "Array") && (args.length == 3)
            result.status = 0
            result.statusMsg = ""

            userName = args[0]
            url = args[1]
            id = args[2]
            ar = url.split("//")
            ar2 = ar[ar.length - 1].to_s.split("/")
            ar2.slice!(0)
            fname = ar2.join("/")
            welformed = ( (fname.length > 0) && (url.include?(fname)) )
            if (ar2.include?("public") == false) then ar2.insert(0,"public") end
            fname = ar2.join("/")
            _exists = (File.exist?(fname) && (welformed))
            result.status = ((_exists) ? 1 : 0)
            a = Array.new
            a.push(url)
            a.push(id)
            result.data = a
        end
        result
    end
	
    def deleteImage(args)
        result = WebOrbResult.new
        result.status = -1
        result.info = "ReportWriter::deleteImage"
        result.statusMsg = "Unable to delete the file"  
        if (args.class.to_s == "Array") && (args.length == 1)
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

            report = args[0]

            elements = ReportBuilder.find_all_by_report_id(report.id)
            elements.each {|e| e.destroy }

            report.destroy
        end
            
        result
    end
	
    def updateReport(args)
        result = WebOrbResult.new
        result.info = "ReportWriter::updateReport"
        result.status = -1
        result.statusMsg = "Invalid args sent to updateReport !"  
        if (args.class.to_s == "Array") && (args.length == 1)
            result.status = 0
            result.statusMsg = ""  
            
            report = args[0]
            report.save!
        end
        
        result
    end
	
    def addEmailAddress(args)
        result = WebOrbResult.new
        result.info = "ReportWriter::addEmailAddress"
        result.status = -1
        result.statusMsg = "Invalid args sent to addEmailAddress !"  
        if (args.class.to_s == "Array") && (args.length == 3)
            result.status = 0
            result.statusMsg = ""  
            
            id = args[0]
            emailAddr = args[1]
            isSelected = args[2]
   
            rd = ReportDistribution.new
            rd.report_id = id
            rd.email_address = emailAddr
            rd.selected = isSelected
            rd.save!
            
            result.status = 0
            result.statusMsg = ""
            result.data = ReportDistribution.find_all_by_report_id(id)
        end
        
        result
    end
	
    def getEmailAddresses(args)
        result = WebOrbResult.new
        result.info = "ReportWriter::getEmailAddresses"
        result.status = -1
        result.statusMsg = "Invalid args sent to getEmailAddresses !"  
        if (args.class.to_s == "Array") && (args.length == 1)
            result.status = 0
            result.statusMsg = ""  
            
            id = args[0]
            
            result.status = 0
            result.statusMsg = ""
            result.data = ReportDistribution.find_all_by_report_id(id)
        end
        
        result
    end
	
    def updateEmailAddress(args)
        result = WebOrbResult.new
        result.info = "ReportWriter::updateEmailAddress"
        result.status = -1
        result.statusMsg = "Invalid args sent to updateEmailAddress !"  
        if (args.class.to_s == "Array") && (args.length == 1)
            result.status = 0
            result.statusMsg = ""  
            
            rd = args[0]
            rd.save!
            
            result.status = 0
            result.statusMsg = ""
            result.data = ReportDistribution.find_all_by_report_id(rd.report_id)
        end
        
        result
    end

    def deleteEmailAddress(args)
        result = WebOrbResult.new
        result.info = "ReportWriter::deleteEmailAddress"
        result.status = -1
        result.statusMsg = "Invalid args sent to deleteEmailAddress !"  
        if (args.class.to_s == "Array") && (args.length == 1)
            result.status = 0
            result.statusMsg = ""  
            
            rd = args[0]
            id = rd.report_id
            rd.destroy
            
            result.status = 0
            result.statusMsg = ""
            result.data = ReportDistribution.find_all_by_report_id(id)
        end
        
        result
    end
    
    def imageToPDF(args)
        result = WebOrbResult.new
        result.info = "ReportWriter::imageToPDF"
        result.status = -1
        result.statusMsg = "Invalid args sent to imageToPDF !"  
        if (args.class.to_s == "Array") && (args.length == 2)
            result.status = 0
            result.statusMsg = ""  
            
            name = args[0]
            username = args[1]
            option = ""
            ar = name.split(".")
            ar[ar.length - 1] = "pdf"
            pdfName = ar.join(".")
            
            pdf = PDF::Writer.new
            i0 = pdf.image name, :resize => 1.0
            pdf.save_as(pdfName)

            result.info += "|" + pdfName.to_s + "|" + option.to_s
        end
        
        result
    end
	
    def saveImage(args)
        result = WebOrbResult.new
        result.info = "ReportWriter::saveImage"
        result.status = -1
        result.statusMsg = "Invalid args sent to saveImage !"  
        if (args.class.to_s == "Array") && (args.length == 4)
            result.status = 0
            result.statusMsg = ""  
			
            name = args[0]
            username = args[1]
            serverFileName = getFileName(name, ((username.length > 0) ? username : "joeUser"))
            bytes = args[2]
            option = args[3]

            begin
                File.exists?(serverFileName) if File.delete(serverFileName)
            rescue
            end
            fhand = File.new(serverFileName, "wb")
            bytes.each {|x| fhand.putc(x) }
            fhand.close
			
            result.info += "|" + serverFileName.to_s + "|" + option.to_s
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
            
            report = args[1]
            newName = args[0]
            report.name = newName
            report.save!
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
        end
        
        result
    end
	
    def getReportElementsForReportById(args)
        result = WebOrbResult.new
        result.info = "ReportWriter::getReportElementsForReportById"
        result.status = -1
        result.statusMsg = "Invalid args sent to getReportElementsForReportById !"  
        if (args.class.to_s == "Array") && (args.length == 1)
            result.status = 0
            result.statusMsg = ""  
            
            id = args[0]
            elements = ReportBuilder.find_all_by_report_id(id)
            if elements.empty? == false
                validElements = Array.new
                elements.each {|e| 
                if (!e.source.nil?) then
                    ar = e.source.split("/uploads/")
                    if ( (e.source.length > 0) && (ar.length == 2) ) then
                        fname = "public/uploads/" + ar[ar.length - 1]
                        if File.exist?(fname) == false then 
                            e.source = ""
                        else
                            x = Array.new
                            x.push(e)
                            img = _getImageSizeForNamedFile(fname)
                            x.push(img.width)
                            x.push(img.height)
                            e = x
                        end
                        validElements.push(e)
                    end
                else
                    validElements.push(e)
                end
                }
                result.status = 1
                result.data = validElements
            end
        end
        
        result
    end
    
    def saveReport(args)
        result = WebOrbResult.new
        result.info = "ReportWriter::saveReport"
        if (args.class.to_s == "Array") && (args.length == 4)
            name = args[0]
            userID = args[1]
            repVO = args[2]
            data = args[3]
            
            if (repVO)
                repVO.name = name
                repVO.save!
                
                dataHash = Hash.new
                data.each {|d| 
                    d.report_id = repVO.id
                    d.save!
                    dataHash[d.id] = d
                }

                allData = ReportBuilder.find_all_by_report_id(repVO.id)
                allData.each {|a|
                    a.destroy if (dataHash.has_key?(a.id) == false)
                }
                result.info += "|" + repVO.id.to_s
            else
                report = Report.new
                report.name = name
                report.user_id = userID
                report.save!
                
                data.each {|d| 
                    d.report_id = report.id
                    d.save! 
                }
            end
            
            result.status = 0  
            result.statusMsg = ""  
        else
            result.status = -1  
            result.statusMsg = "Argument is not an Array. Cannot process the report."  
        end
        result
    end
    
    def cloneReport(args)
        result = WebOrbResult.new
        result.info = "ReportWriter::cloneReport"
        if (args.class.to_s == "Array") && (args.length == 1)
            repVO = args[0]

            isOk = false
            newName = repVO.name
            while isOk == false
                begin
                    report = Report.new
                    report.name = newName + "-copy"
                    report.user_id = repVO.user_id
                    report.next_scheduled_run = repVO.next_scheduled_run
                    report.save!
                    
                    allData = ReportBuilder.find_all_by_report_id(repVO.id)
                    allData.each {|e|
                        rb = ReportBuilder.new
                        rb.report_id = report.id
                        rb.shape_type = e.shape_type
                        rb.x = e.x
                        rb.y = e.y
                        rb.width = e.width
                        rb.height = e.height
                        rb.widget_id = e.widget_id
                        rb.widget_name = e.widget_name
                        rb.text = e.text
                        rb.source = e.source
                        rb.save!
                    }
                    isOk = true
                rescue
                    newName += "-copy"
                end
            end
   
            result.info = "ReportService::getReportsForUser"
            result.data = Report.find_all_by_user_id(repVO.user_id)
                
            result.status = 0  
            result.statusMsg = "" 
        else
            result.status = -1  
            result.statusMsg = "Argument is not an Array. Cannot process the report."  
        end
        result
    end
end
