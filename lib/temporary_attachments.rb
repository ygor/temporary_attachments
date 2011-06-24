module TemporaryAttachments
  def self.included(base)
    base.extend ClassMethods
    base.instance_eval do
      #after_validation :preserve_attachments
    end
  end
  
  module ClassMethods
    def has_temporary_attachments(*names)
      write_inheritable_array(:temporary_attachments, names)
      names.each { |name|
        attr_accessor "#{name}_temp_attachment".to_sym
        
        define_method("#{name}_temp_attachment_id=") do |temp_attachment_id|
          temp = TempAttachment.find_by_id(temp_attachment_id)
          unless temp.nil?
            self.send("#{name}_temp_attachment=", temp)
            self.send("#{name}=", temp.file)
          end
        end
      }
    end
  end
  
  def preserve_attachments
    # loop through all our potential files
    # remove their reference if the file hasn't been set
    
    temporary_attachments.reject { |name|
      !self.send("#{name}?") || self.send(name).queued_for_write[:original].nil? || !self.errors[name].empty?
    # loop through all the existing files
    }.each { |name|
      # destroy possible earlier temp_file
      current = self.send("#{name}_temp_attachment")
      current.destroy unless current.nil?
    
      # store upload in new temp file
      if self.errors[name].empty? && self.errors["#{name}_content_type"].empty?
        file_path = self.send(name).queued_for_write[:original].path
        temp = ::TempAttachment.create(:file => File.new(file_path))    
        self.send("#{name}_temp_attachment=", temp)
      end
    }
  end
  
  private
  # returns an array of the files that are used by Paperclip
  def temporary_attachments
    self.class.read_inheritable_attribute(:temporary_attachments) || []
  end
end

ActiveRecord::Base.send :include, TemporaryAttachments