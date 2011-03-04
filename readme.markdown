Welcome to Temporary Uploads
==========================

Temporarily save a valid uploaded paperclip attachment when the form of a new active record instance has other validation errors.  

How do I use it?
----------------

First include the library in your class:

    include TemporaryUploads

For each attachment that should be uploaded temporarily add

    has_temporary_uploads :attachment_name
    
Run the this migration

    class CreateTempUploads < ActiveRecord::Migration
      def self.up
        create_table :temp_uploads do |t|
          t.string :file_file_name
          t.string :file_content_type
          t.integer :file_file_size
          t.datetime :file_updated_at
          t.timestamps
        end
      end

      def self.down
        drop_table :temp_uploads
      end
    end

In your resource controller, add the following call to preserve_uploads

    def create
      unless @model.save
        redirect_to #
      else
        @model.preserve_uploads
        render :new
      end
    end

Then in your views do

    <% if f.object.attachment_name_temp_upload.present?%>
       <div>
         <%= f.hidden_field :attachment_name_temp_upload_id, :value => f.object.attachment_name_temp_upload.id, :class => 'temp_upload' %>
         <%= image_tag f.object.attachment_name_temp_upload.file.url(:thumb) # use this if your attachment is an image %>
         <p><%= content_tag :span, 'Clear', :class => 'link', :onclick => '$(this).closest(\'div\').find(\'input.temp_upload\').val(0);$(this).closest(\'div\').hide();'%></p>
       </div>  
     <% end %>

That's it!
