module GroupHelper
  def learning_path_content_type(type)
    case type
    when "Program"
      return "Programa"
    when "Quiz"
      return "Examen"
    when "TemplateRefilable"
     return "Rellenable"
    when "DelireverablePackage"
      return "Entregable"
    else
      return "N/A"  
    end
  end
end
