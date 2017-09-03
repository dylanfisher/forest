module MetaHelper
  def page_title
    a = [content_for(:page_title) || @page_title, site_title].reject(&:blank?).join(divider).squish
    stripdown(a)
  end

  def site_title
    a = Setting.for('site-title')&.value || default_site_title
    stripdown(a)
  end

  def page_description
    a = [content_for(:page_description) || @page_description, site_description].reject(&:blank?).first.squish
    stripdown(a)
  end

  def page_keywords
    [content_for(:page_keywords), Setting.for('page-keywords')&.value].reject(&:blank?).first
  end

  def page_featured_image
    [content_for(:page_featured_image), site_featured_image].reject(&:blank?).first
  end

  def site_description
    Setting.for('description')&.value || default_site_description
  end

  def site_featured_image
    Setting.for('featured-image')&.value
  end

  def meta_see_also
    [content_for(:meta_see_also), root_path].reject(&:blank?).first
  end

  def meta_type
    [content_for(:meta_type), default_meta_type].reject(&:blank?).first
  end

  def meta_url
    [content_for(:meta_url), (request.base_url + request.path)].reject(&:blank?).first
  end

  def meta_viewport
    [content_for(:meta_viewport), 'width=device-width'].reject(&:blank?).first
  end

  def additional_meta_tags
    content_for(:additional_meta_tags)
  end

  private

    def default_site_title
      'Forest CMS'
    end

    def default_site_description
      'This site was built with Forest, a Ruby on Rails CMS.'
    end

    def default_meta_type
      'website'
    end

    def divider(spacer = ' – ')
      spacer
    end
end
