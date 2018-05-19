module MetaHelper
  def meta_page_title
    @_meta_page_title ||= begin
      title = [
        page_title,
        site_title
      ].reject(&:blank?).join(divider)
      stripdown(title).squish
    end
  end

  def page_title
    @_page_title ||= begin
      title = [
        content_for(:page_title),
        @page_title,
        build_page_title_from_record,
        build_page_title_from_controller
      ].reject(&:blank?).first
      stripdown(title).squish
    end
  end

  def site_title
    @_site_title ||= begin
      title = Setting.for('site_title') || default_site_title
      stripdown(title).squish
    end
  end

  def page_description
    @_page_description ||= begin
      description = [
        content_for(:page_description),
        @page_description,
        build_page_description_from_record,
        site_description
      ].reject(&:blank?).first.squish
      stripdown(description).squish
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
      image = [
        content_for(:page_featured_image),
        @page_featured_image,
        build_page_featured_image_from_record,
        site_featured_image
      ].reject(&:blank?).first

      if image.respond_to?(:attachment)
        image = image.attachment
      end

      image
    end
  end

  def page_featured_image_url
    begin
      @_page_featured_image_url ||= begin
        if page_featured_image.is_a?(String)
          url = page_featured_image
        end

        if page_featured_image.is_a?(Paperclip::Attachment)
          if page_featured_image.options[:styles].keys.include?(:large)
            style = :large
          else
            style = page_featured_image.options[:styles].keys.last
          end
          url = page_featured_image.url(style)
        end

        url
      end
    rescue Exception => e
    end
  end

  def page_featured_image_width
    @_page_featured_image_width ||= begin
      return unless page_featured_image.is_a?(Paperclip::Attachment)
      page_featured_image.instance.try(:dimensions).try(:[], :width) ||
        page_featured_image.instance.try(:attachment_width)
    end
  end

  def page_featured_image_height
    @_page_featured_image_height ||= begin
      return unless page_featured_image.is_a?(Paperclip::Attachment)
      page_featured_image.instance.try(:dimensions).try(:[], :height) ||
        page_featured_image.instance.try(:attachment_height)
    end
  end

  def page_featured_image_type
    @_page_featured_image_type ||= begin
      return unless page_featured_image.is_a?(Paperclip::Attachment)
      page_featured_image.try(:attachment_content_type)
    end
  end

  def page_featured_image_alt
    @_page_featured_image_alt ||= begin
      return unless page_featured_image.is_a?(Paperclip::Attachment)
      page_featured_image.try(:alternative_text)
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
        (request.base_url + request.path)
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
      @_build_page_description_from_record ||= begin
        description = record_to_build_from.try(:to_page_description) ||
          record_to_build_from.try(:description)
        truncate(description, length: 240)
      end
    end

    def build_page_featured_image_from_record
      @_build_page_featured_image_from_record ||= begin
        record_to_build_from.try(:featured_image).presence ||
          record_to_build_from.try(:media_item).presence
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
