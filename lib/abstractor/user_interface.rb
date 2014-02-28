module Abstractor
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
  end
end
