module NavbarHelper
  def display_navbar_link(options)
    item = content_tag(:li, class: options [:css]) do
      concat(content_tag(:a, nil, href: options[:path], class: ['detailed']) do
        concat content_tag(:span, options[:link], class: 'title')
        concat content_tag(:span, options[:details], class: 'details')
      end)

      concat(content_tag(:span, nil, class: 'icon-thumbnail') do
        content_tag(:i, nil, class: "#{options[:icon]}")
      end)
    end

    have_access = options[:role].include?(current_user.role.to_sym)
    return item if have_access
  end
end
