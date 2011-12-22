class String
  def safe_markdown
    RDiscount.new(self).to_html.html_safe
  end
end