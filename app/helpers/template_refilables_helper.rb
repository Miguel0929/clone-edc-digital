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
end
