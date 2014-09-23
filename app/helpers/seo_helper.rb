module SeoHelper
  def seo_title
     base_title = "Royal Brands shop"
     if @title.present?
       "#{@title} | #{base_title}"
     else
       base_title
     end
   end
   
  def meta_seo_description
    base_meta_description = ""
    if @seo_description.present?
     @seo_description
    else
     base_meta_description
    end
  end

  def meta_seo_text
    base_meta_text = ""
    if @seo_text.present?
      @seo_text
    else
      base_meta_text
    end
  end
   
end
