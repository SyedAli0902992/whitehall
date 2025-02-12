class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def append_url_options(path, options = {})
    locale = normalise_locale(options[:locale])

    if options[:format] && options[:locale] && locale != I18n.default_locale
      path = "#{path}.#{options[:locale]}.#{options[:format]}"
    elsif options[:locale] && locale != I18n.default_locale
      path = "#{path}.#{options[:locale]}"
    elsif options[:format]
      path = "#{path}.#{options[:format]}"
    end

    query_params = {}
    query_params[:cachebust] = options[:cachebust] if options[:cachebust]
    query_params[:preview] = options[:preview] if options[:preview]

    path = "#{path}?#{query_params.to_query}" unless query_params.empty?

    path = "#{path}##{options[:anchor]}" if options[:anchor]

    path
  end

private

  def normalise_locale(locale)
    case locale
    when Struct
      locale.code
    when String
      locale.to_sym
    when Symbol
      locale
    end
  end
end
