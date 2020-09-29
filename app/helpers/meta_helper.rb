module MetaHelper
  def meta_page_title
    @_meta_page_title ||= begin
      title = []

      if ft(record_to_build_from, :seo_title, call_method: :try, fallback: true).present?
        title << ft(record_to_build_from, :seo_title, fallback: true)
      else
        title << page_title unless controller_name == 'home_pages'
        title << site_title
      end

      title = title.reject(&:blank?).join(divider)
      sanitize stripdown(title).squish
    end
  end

  def page_title
    @_page_title ||= begin
      return if @disable_page_title.present?
      title = [
        content_for(:page_title),
        @page_title,
        build_page_title_from_record,
        build_page_title_from_controller
      ].reject(&:blank?).first
      sanitize stripdown(title).squish
    end
  end

  def site_title
    @_site_title ||= begin
      title = Setting.for('site_title') || default_site_title
      sanitize stripdown(title).squish
    end
  end

  def page_description
    @_page_description ||= begin
      description = [
        content_for(:page_description),
        @page_description,
        build_page_description_from_record,
        site_description
      ].reject(&:blank?).first.try(:squish)
      sanitize stripdown(description).squish
    end
  end

  def page_keywords
    @_page_keywords ||= begin
      [
        content_for(:page_keywords),
        Setting.for('page_keywords')
      ].reject(&:blank?).first.try(:squish)
    end
  end

  def page_featured_image
    @_page_featured_image ||= begin
      [
        content_for(:page_featured_image),
        @page_featured_image,
        build_page_featured_image_from_record,
        site_featured_image
      ].reject(&:blank?).first
    end
  end

  def page_featured_image_url
    begin
      @_page_featured_image_url ||= begin
        if page_featured_image.is_a?(String)
          url = page_featured_image
        end

        if page_featured_image.is_a?(MediaItem)
          url = page_featured_image.attachment_url(:large)
        end

        url
      end
    rescue Exception => e
    end
  end

  def page_featured_image_width
    @_page_featured_image_width ||= begin
      return unless page_featured_image.is_a?(MediaItem)
      @page_featured_image_width ||
        page_featured_image.try(:dimensions).try(:[], :width) ||
        page_featured_image.try(:width)
    end
  end

  def page_featured_image_height
    @_page_featured_image_height ||= begin
      return unless page_featured_image.is_a?(MediaItem)
      @page_featured_image_height ||
        page_featured_image.try(:dimensions).try(:[], :height) ||
        page_featured_image.try(:height)
    end
  end

  def page_featured_image_type
    @_page_featured_image_type ||= begin
      return unless page_featured_image.is_a?(MediaItem)
      page_featured_image.try(:attachment_content_type)
    end
  end

  def page_featured_image_alt
    @_page_featured_image_alt ||= begin
      return unless page_featured_image.is_a?(MediaItem)
      if page_featured_image.present?
        ft(page_featured_image, :alternative_text, call_method: :try, fallback: true)
      end
    end
  end

  def site_description
    @_site_description ||= begin
      (Setting.for('description') || default_site_description).try(:squish)
    end
  end

  def site_featured_image
    @_site_featured_image ||= begin
      Setting.for('featured_image')
    end
  end

  def meta_see_also
    @_meta_see_also ||= begin
      [
        content_for(:meta_see_also),
        root_path
      ].reject(&:blank?).first
    end
  end

  def meta_type
    @_meta_type ||= begin
      [
        content_for(:meta_type),
        default_meta_type
      ].reject(&:blank?).first
    end
  end

  def meta_url
    @_meta_url ||= begin
      [
        content_for(:meta_url),
        (request.base_url.dup.force_encoding('utf-8') + request.path.force_encoding('utf-8'))
      ].reject(&:blank?).first
    end
  end

  def meta_viewport
    @_meta_viewport ||= begin
      [
        content_for(:meta_viewport),
        'width=device-width, initial-scale=1.0'
      ].reject(&:blank?).first
    end
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

  def divider(spacer = ' - ')
    spacer
  end

  def build_page_title_from_record
    ft(record_to_build_from, :to_page_title, call_method: :try, fallback: true) ||
    ft(record_to_build_from, :title, call_method: :try, fallback: true) ||
    ft(record_to_build_from, :name, call_method: :try, fallback: true)
  end

  def build_page_title_from_controller
    if controller_name == 'home_pages'
      'Home'
    else
      controller_name.titleize
    end
  end

  def build_page_description_from_record
    @_build_page_description_from_record ||= begin
      description = ft(record_to_build_from, :to_page_description, call_method: :try, fallback: true) ||
        ft(record_to_build_from, :description, call_method: :try, fallback: true)
      truncate(description, length: 240)
    end
  end

  def build_page_featured_image_from_record
    @_build_page_featured_image_from_record ||= begin
      record_to_build_from.try(:featured_image).presence ||
        record_to_build_from.try(:media_item).presence ||
        record_to_build_from.try(:blockable_metadata).try(:[], 'featured_image_url').presence
    end
  end

  def record_to_build_from(record = nil)
    @_record_to_build_from ||= begin
      record.presence ||
        @page.presence ||
        @record.presence ||
        instance_variable_get("@#{controller_name.singularize}").presence
    end
  end
end
