Welcome to Temporary Attachments
==========================

Temporarily save a valid uploaded paperclip attachment when the form of a new active record instance has other validation errors.  

How do I use it?
----------------

For the attachments that should be uploaded temporarily add

    has_temporary_attachments :attachment1_name, :attachment2_name
    
Run the this migration

    class CreateTempAttachments < ActiveRecord::Migration
      def self.up
        create_table :temp_attachments do |t|
          t.string :file_file_name
          t.string :file_content_type
          t.integer :file_file_size
          t.datetime :file_updated_at
          t.timestamps
        end
      end

      def self.down
        drop_table :temp_attachments
      end
    end

Create the file models/temp_attachment.rb and add

    class TempAttachment < ActiveRecord::Base
      has_attached_file :file, :styles => { :medium => "420x320#", :thumb => "100x100>" }
    end

In your resource controller, add the following call to preserve_attachments

    def create
      unless @model.save
        redirect_to #
      else
        @model.preserve_attachments
        render :new
      end
    end

Then in your views do

    <% if f.object.attachment_name_temp_attachment.present?%>
       <div>
         <%= f.hidden_field :attachment_name_temp_attachment_id, :value => f.object.attachment_name_temp_attachment.id, :class => 'temp_attachment' %>
         <%= image_tag f.object.attachment_name_temp_attachment.file.url(:thumb) %> <!-- only use this if your file is an image -->
         <p><%= content_tag :span, 'Clear', :class => 'link', :onclick => '$(this).closest(\'div\').find(\'input.temp_attachment\').val(0);$(this).closest(\'div\').hide();'%></p>
       </div>  
     <% end %>

That's it!
