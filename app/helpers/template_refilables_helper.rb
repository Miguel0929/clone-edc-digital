module TemplateRefilablesHelper
  def replace_fillable(content)
    content.gsub(
      "{{rellenable}}",
      '<span class="refilable-edit" style="font-weight:bold;">_____</span>'
    )
  end

  def remove_class(content)
    content.gsub("editable",'')
  end
end
