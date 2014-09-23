module Jekyll
  $cheat_sheets = begin
                    YAML.load_file("external/cheat/cheat.yaml")
                  rescue
                    puts "Warning: did not find YAML cheat definitions."
                    {}
                  end

  class CheatSheetTag < Liquid::Tag
    def render(context)
      output = "<ul class=\"cheat-sheets\">"
      $cheat_sheets.each do |text, link|
        output << %{<li><a href="#{link}">#{text}</a></li>}
        output << "\n"
      end
      output << '</ul>'
      output
    end
  end
  Liquid::Template.register_tag('cheat_sheet', Jekyll::CheatSheetTag)


  class RedirectPage < Page
    def initialize(site, base, dir, data)
      @site = site
      @base = base
      @dir = dir
      @name = "#{data['text']}.html"
      self.data = data

      self.process(@name)
      self.read_yaml(File.join(base, '_layouts'), 'redirect.html')
    end
  end

  class CheatSheetRedirectGenerator < Generator
    safe true

    def generate(site) 
      puts "Generating cheat redirect pages."
      $cheat_sheets.each do |text, link|
        site.pages << RedirectPage.new(site, site.source, "cheat", {'text' => text, 'link' => link})
      end
    end
  end
end
