module Abstractor
  ##
  # A collection of helper methods used in the Abstactor user interface.
  module UserInterface
    #2/16/2014 MGURLEY Stolen from http://api.rubyonrails.org/classes/ActionView/Helpers/TextHelper.html.  Rails 3.2.16.
    #                 Removed the cleverness trying skip highlighting content it thinks is html markup.
    def self.highlight(text, phrases, *args)
      options = args.extract_options!
      unless args.empty?
        options[:highlighter] = args[0] || '<strong class="highlight">\1</strong>'
      end
      options.reverse_merge!(:highlighter => '<strong class="highlight">\1</strong>')

      # text = sanitize(text) unless options[:sanitize] == false
      if text.blank? || phrases.blank?
        text
      else
        match = Array(phrases).map { |p| Regexp.escape(p) }.join('|')
        text.gsub(/(#{match})/i, options[:highlighter])
      end.html_safe
    end

    ##
    # Transforms a path to account for a relative url root.
    # URL helpers in Rails Engine views and partials embedded in view in the host application don't play well with relative url roots.
    # @param path [String] the URL path that should have a relative prefix added if needed
    # @return [String] the processed URL
    def self.abstractor_relative_path(path)
      prefix = Rails.application.config.action_controller.relative_url_root

      if prefix.blank? || path.include?(prefix)
        url = path
      else
        url = prefix + path
      end

      url
    end
  end
end