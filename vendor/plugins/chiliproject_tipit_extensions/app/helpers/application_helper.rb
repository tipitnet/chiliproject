
module ApplicationHelper

  def user_projects_for_select(user)
    user.projects.collect{|proj| [ proj.name, proj.id]}.sort{|x,y| x.last <=> y.last }
  end

  def replace_images_for_links(input, issue)
    @doc = Nokogiri::HTML(input.strip)
    @doc.css('img').each do |node|
      href = node.attr("src")

      if !href.start_with?("http") && !issue.nil?
        filename = href
        attachments = issue.attachments.sort_by(&:created_on).reverse
        # search for the picture in attachments
        if found = attachments.detect { |att| att.filename.downcase == filename }
          image_url = url_for :only_path => only_path, :controller => 'attachments', :action => 'download', :id => found
          href = image_url
        end
      end

      anchor = "[Inline Image: <a href=\"#{href}\">link</a> ]"
      node.replace(anchor)
    end
    @doc.css('body').children.to_s
  end

end