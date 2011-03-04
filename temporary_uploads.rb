module TemporaryUploads
  def self.included(base)
    base.extend ClassMethods
    base.instance_eval do
      #after_validation :preserve_uploads
    end
  end
  
  module ClassMethods
    def has_temporary_uploads(*names)
      write_inheritable_array(:temporary_upload_files, names)
      names.each { |name|
        attr_accessor "#{name}_temp_upload".to_sym

        define_method("#{name}_temp_upload_id=") do |temp_upload_id|
          temp = TempUpload.find_by_id(temp_upload_id)
          unless temp.nil?
            self.send("#{name}_temp_upload=", temp)
            self.send("#{name}=", temp.file)
          end
        end
      }
    end
  end
  
  def preserve_uploads
    # loop through all our potential files
    # remove their reference if the file hasn't been set
    
    temporary_upload_files.reject { |name|
      !self.send("#{name}?") || self.send(name).queued_for_write[:original].nil? || !self.errors[name].empty?
    # loop through all the existing files
    }.each { |name|
      # destroy possible earlier temp_file
      current = self.send("#{name}_temp_upload")
      current.destroy unless current.nil?
    
      # store upload in new temp file
      if self.errors[name].empty? && self.errors["#{name}_content_type"].empty?
        file_path = self.send(name).queued_for_write[:original].path
        temp = TempUpload.create(:file => File.new(file_path))    
        self.send("#{name}_temp_upload=", temp)
      end
    }
  end
  
  private
  # returns an array of the files that are used by Paperclip
  def temporary_upload_files
    self.class.read_inheritable_attribute(:temporary_upload_files) || []
  end
end