module NavbarHelper
  def display_navbar_link(link_name, path, level_access, plus_member = false)
    item = content_tag(:li, link(link_name, path), class: ['nav-item'])

    have_access = level_access.include?(current_user.role.to_sym)
    return item if have_access || plus_member
  end

  private
  def link(link_name, path)
    content_tag(:a, link_name, href: path)
  end
end
