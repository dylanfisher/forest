module MetaHelper
  def meta_page_title
    title = [
      page_title,
      site_title
    ].reject(&:blank?).join(divider)
    stripdown(title).squish
  end

  def page_title
    title = [
      content_for(:page_title),
      @page_title,
      build_page_title_from_record,
      build_page_title_from_controller
    ].reject(&:blank?).first
    stripdown(title).squish
  end

  def site_title
    a = Setting.for('site-title')&.value || default_site_title
    stripdown(a).squish
  end

  def page_description
    description = [
      content_for(:page_description),
      @page_description,
      build_page_description_from_record,
      site_description
    ].reject(&:blank?).first.squish
    stripdown(description).squish
  end

  def page_keywords
    [
      content_for(:page_keywords),
      Setting.for('page-keywords')&.value
    ].reject(&:blank?).first.try(:squish)
  end

  def page_featured_image
    [
      content_for(:page_featured_image),
      build_page_featured_image_from_record,
      site_featured_image
    ].reject(&:blank?).first.try(:squish)
  end

  def site_description
    (Setting.for('description')&.value || default_site_description).try(:squish)
  end

  def site_featured_image
    Setting.for('featured-image')&.value
  end

  def meta_see_also
    [
      content_for(:meta_see_also),
      root_path
    ].reject(&:blank?).first
  end

  def meta_type
    [
      content_for(:meta_type),
      default_meta_type
    ].reject(&:blank?).first
  end

  def meta_url
    [
      content_for(:meta_url),
      (request.base_url + request.path)
    ].reject(&:blank?).first
  end

  def meta_viewport
    [
      content_for(:meta_viewport),
      'width=device-width'
    ].reject(&:blank?).first
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

    def build_page_title_from_record
      record_to_build_from.try(:to_page_title) ||
      record_to_build_from.try(:title) ||
      record_to_build_from.try(:name)
    end

    def build_page_title_from_controller
      controller_name.titleize
    end

    def build_page_description_from_record
      description = build_page_title_from_record.try(:to_page_description) ||
        build_page_title_from_record.try(:description)
      truncate(description, length: 240)
    end

    def build_page_featured_image_from_record
      image = record_to_build_from.try(:featured_image)
      if image.present?
        url = image.try(:attachment).try(:url, :large)
      end
      url
    end

    def record_to_build_from(record = nil)
      @_record_to_build_from ||= begin
        record.presence || @page.presence || @record.presence
      end
    end
end
