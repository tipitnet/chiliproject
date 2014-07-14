require_dependency 'wiki_controller'

module TipitExtensions

  module WikiControllerPatch

    def self.included(base) # :nodoc:
      base.extend(ClassMethods)

      base.send(:include, InstanceMethods)

      # Same as typing in the class
      base.class_eval do
        alias_method_chain :update, :tipit_patch
        alias_method_chain :show, :tipit_patch
        alias_method_chain :initial_page_content, :tipit_patch
      end

    end

    module ClassMethods
    end

    module InstanceMethods

      # This method is in the chain but it interrupt because it replaces the original method
      def update_with_tipit_patch
        @page = @wiki.find_or_new_page(params[:id])
        return render_403 unless editable?
        if @page.new_record?
          @page.content = WikiContent.new(:page => @page)
          @page.parent_id = params[:parent_id] unless @page.title == @wiki.start_page
        end

        @content = @page.content_for_version(params[:version])
        @content.text = initial_page_content(@page) if @content.text.blank?
        # don't keep previous comment
        @content.comments = nil

        if !@page.new_record? && params[:content].present? && @content.text == params[:content][:text]
          attachments = Attachment.attach_files(@page, params[:attachments])
          render_attachment_warning_if_needed(@page)
          # don't save if text wasn't changed
          redirect_to :action => 'show', :project_id => @project, :id => @page.title
          return
        end
        params[:content].delete(:version) # The version count is automatically increased
        @content.attributes = params[:content]
        @content.author = User.current
        # if page is new @page.save will also save content, but not if page isn't a new record
        if (@page.new_record? ? @page.save : @content.save)
          attachments = Attachment.attach_files(@page, params[:attachments])
          render_attachment_warning_if_needed(@page)
          call_hook(:controller_wiki_edit_after_save, { :params => params, :page => @page})
          redirect_to :action => 'show', :project_id => @project, :id => @page.title
        else
          render :action => 'edit'
        end

      rescue ActiveRecord::StaleObjectError
        # Optimistic locking exception
        flash.now[:error] = l(:notice_locking_conflict)
        render :action => 'edit'
      end

      def show_with_tipit_patch
        page_title = params[:id]
        @page = @wiki.find_or_new_page(page_title)
        if @page.new_record?
          if User.current.allowed_to?(:edit_wiki_pages, @project) && editable?
            @page.parent_id = session[:current_page_id] unless @page.title == @wiki.start_page
            edit
            render :action => 'edit'
          else
            render_404
          end
          return
        end
        session[:current_page_title] = @page.title
        session[:current_page_id] = @page.id
        if params[:version] && !User.current.allowed_to?(:view_wiki_edits, @project)
          # Redirects user to the current version if he's not allowed to view previous versions
          redirect_to :version => nil
          return
        end
        @content = @page.content_for_version(params[:version])
        if User.current.allowed_to?(:export_wiki_pages, @project)
          if params[:format] == 'html'
            export = render_to_string :action => 'export', :layout => false
            send_data(export, :type => 'text/html', :filename => "#{@page.title}.html")
            return
          elsif params[:format] == 'txt'
            send_data(@content.text, :type => 'text/plain', :filename => "#{@page.title}.txt")
            return
          end
        end
        @editable = editable?
      end

      def initial_page_content_with_tipit_patch(page)
        wiki_template = "h1. #{page.pretty_title} \n\r"
        wiki_template += page.project.wiki_template
        wiki_template
      end

    end
  end

end