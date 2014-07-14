
module ApplicationHelper

  def user_projects_for_select(user)
    user.projects.collect{|proj| [ proj.name, proj.id]}.sort{|x,y| x.last <=> y.last }
  end

end