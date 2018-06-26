module LinkHelper
  def active_link_class(link_path)
    current_page?(link_path) ? 'active' : ''
  end
end