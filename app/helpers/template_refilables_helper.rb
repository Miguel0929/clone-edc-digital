module TemplateRefilablesHelper
  def replace_fillable(content)
    content.gsub(
      "{{rellenable}}",
      '<span class="refilable-edit" style="font-weight:bold;"></span>'
    )
  end

  def replace_fillable_admin(content)
    content.gsub(
      "{{rellenable}}",
      '<span class="refilable-edit" style="font-weight:bold;">______</span>'
    )
  end

  def remove_class(content)
    content.gsub("editable",'')
  end

  def replace_refilable_data(refilable)
    replacements = [ 
                    ["{{alumno}}", User.find(refilable.user_id).first_name], 
                    ["{{tutor}}", (refilable.mentor_id.nil? ? '<span class="text-danger">dato indefinido</span>' : User.find(refilable.mentor_id).name)], 
                    ["{{programa}}", (refilable.template_refilable.nil? ? '<span class="text-danger">dato indefinido</span>' : refilable.template_refilable.program.name)], 
                    ["{{plantilla}}", refilable.template_refilable.name], 
                    ["{{puntaje}}", (refilable.points.nil? ? '<span class="text-danger">dato indefinido</span>' : (refilable.points.to_s + "%"))] 
                   ]
    user_comments = refilable.comments
    replacements.each {|replacement| user_comments.gsub!(replacement[0], replacement[1])}
    return user_comments
  end
end