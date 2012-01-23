class String
  def safe_markdown
    RDiscount.new(self, :no_image).to_html.html_safe
  end
end