# Heavily adapted from:
# https://github.com/apache/buildr/blob/trunk/rakelib/doc.rake

module Jekyll
  class TableOfContentsTag < Liquid::Tag
    @@link_regexp = /\[([^\]]*)\]\([^\)]*\)/

    def initialize(tag_name, text, tokens)
      super
      @text = text
    end
    
    # TODO subheadings
    #
    def render(context)
      content = context.environments.first["page"]["content"]
      output = "<section><span class=\"toc\"><ol class=\"toc\">"
      content.scan(/^## (.*?)$/mi).each_with_index do |line, index|
        title = line[0]
        
        title.gsub!(@@link_regexp) do |link|
          link.match(@@link_regexp)[1]
        end
        output << %{<li><a href="#toc_#{index}">#{title}</a></li>}
      end
      output << '</ol></span></section>'
      output
    end
  end

  Liquid::Template.register_tag('toc', Jekyll::TableOfContentsTag)
end
