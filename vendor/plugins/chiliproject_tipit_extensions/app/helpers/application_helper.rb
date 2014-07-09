
module ApplicationHelper

  def user_projects_for_select(user)
    user.projects.collect{|proj| [ proj.name, proj.id]}.sort{|x,y| x.last <=> y.last }
    #valid_languages.collect{|lang| [ ll(lang.to_s, :general_lang_name), lang.to_s]}.sort{|x,y| x.last <=> y.last }
  end

end