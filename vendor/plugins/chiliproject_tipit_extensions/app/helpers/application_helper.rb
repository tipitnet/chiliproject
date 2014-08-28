
module ApplicationHelper

  def user_projects_for_select(user)
    user.projects.collect{|proj| [ proj.name, proj.id]}.sort{|x,y| x.last <=> y.last }
  end

  def replace_images_for_links(input)
    @doc = Nokogiri::HTML(input.strip)
    @doc.css('img').each do |node|
      href = node.attr("src")
      anchor = "[Inline Image: <a href=\"#{href}\">link</a> ]"
      node.replace(anchor)
    end
    @doc.css('body').children.to_s
  end

end