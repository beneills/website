module Jekyll

  # Based on "Footnotes" plugin.
  #
  # We generate valid HTML5
  #

  class Convenience
    def self.superscript_html(body)
      "<sup class=\"state-of-the-realm-superscript\">#{body}</sup>"
    end

    def self.href_html(link, body)
      "<a class=\"state-of-the-realm-link\" href=\"#{link}\">#{body}</a>"
    end

    def self.evidence_html(type, id, body)
      href_html("##{type}-#{id}", body)
    end

    def self.untyped_label_html(label)
      "<span class=\"state-of-the-realm-label\">#{label}</span>"
    end

    def self.typed_label_html(type, value)
      raise ArgumentError if ['"', '<', '>'].any? { |c| type.include?(c) } or type.length < 1
      raise ArgumentError if ['"', '<', '>'].any? { |c| value.include?(c) }

      type_html = "<span class=\"state-of-the-realm-type\">#{type}</span>"
      value_html = "<span class=\"state-of-the-realm-value\">#{value}</span>"

      untyped_label_html "#{type_html}#{value_html}"
    end

    def self.fact_html(id)
      raise ArgumentError if ['"', '<', '>'].any? { |c| id.include?(c) }

      superscript_html evidence_html('fact', id, typed_label_html('f', id))
    end

    def self.conjecture_html(id)
      raise ArgumentError if ['"', '<', '>'].any? { |c| id.include?(c) }

      superscript_html evidence_html('conjecture', id, typed_label_html('c', id))
    end

    def self.statement_html(id)
      raise ArgumentError if ['"', '<', '>'].any? { |c| id.include?(c) }

      superscript_html typed_label_html('s', id)
    end

    def self.footnote_html(id)
      raise ArgumentError if ['"', '<', '>'].any? { |c| id.include?(c) }

      superscript_html evidence_html('footnote', id, typed_label_html('f', id))
    end

    def self.inference_html(premises)
      raise ArgumentError if ['"', '<', '>'].any? { |c| premises.include?(c) }

      superscript_html typed_label_html('&#8866;', premises)
    end
  end

  class StateOfTheRealmIds
    @@highest_ref_id = 0
    @@highest_evidence_id = 0

    @@providing_evidence = false

    def self.ref(id)
      raise SyntaxError.new("out of order ref ID") unless id.to_i == next_ref_id
      raise SyntaxError.new("providing evidence") if @@providing_evidence

      @@highest_ref_id = next_ref_id
    end

    def self.evidence(id)
      raise SyntaxError.new("out of order evidence ID") unless id.to_i == next_evidence_id
      raise SyntaxError.new("too high evidence ID") unless next_evidence_id <= @@highest_ref_id

      @@providing_evidence = true

      @@highest_evidence_id = next_evidence_id
    end

    def self.check_finished
      raise SyntaxError.new("not enough evidence") unless finished?
    end

    def self.reset
      @@highest_ref_id = 0
      @@highest_evidence_id = 0
      @@providing_evidence = false
    end

    private

    def self.next_ref_id
      1 + @@highest_ref_id
    end

    def self.next_evidence_id
      1 + @@highest_evidence_id
    end

    def self.finished?
      @@highest_ref_id == @@highest_evidence_id
    end
  end

  class StateOfTheRealmFactTag < Liquid::Tag
    def initialize(tag_name, id, tokens)
      raise(SyntaxError.new("invalid tag ID")) if ['"', '<', '>'].any? { |c| id.include?(c) }
      raise(SyntaxError.new("no ID")) if id.strip.empty?

      StateOfTheRealmIds::ref id

      @id = id.strip unless id.strip.empty?
      super
    end

    def render(context)
      Jekyll::Convenience::fact_html @id
    end
  end

  class StateOfTheRealmConjectureTag < Liquid::Tag
    def initialize(tag_name, id, tokens)
      raise(SyntaxError.new("invalid tag ID")) if ['"', '<', '>'].any? { |c| id.include?(c) }
      raise(SyntaxError.new("no ID")) if id.strip.empty?

      StateOfTheRealmIds::ref id

      @id = id.strip unless id.strip.empty?
      super
    end

    def render(context)
      Jekyll::Convenience::conjecture_html @id
    end
  end

  class StateOfTheRealmStatementTag < Liquid::Tag
    def initialize(tag_name, id, tokens)
      raise(SyntaxError.new("invalid tag ID")) if ['"', '<', '>'].any? { |c| id.include?(c) }
      raise(SyntaxError.new("no ID")) if id.strip.empty?

      StateOfTheRealmIds::ref id

      @id = id.strip unless id.strip.empty?
      super
    end

    def render(context)
      Jekyll::Convenience::statement_html @id
    end
  end

  class StateOfTheRealmFootnoteTag < Liquid::Tag
    def initialize(tag_name, id, tokens)
      raise(SyntaxError.new("invalid tag ID")) if ['"', '<', '>'].any? { |c| id.include?(c) }
      raise(SyntaxError.new("no ID")) if id.strip.empty?

      StateOfTheRealmIds::ref id

      @id = id.strip unless id.strip.empty?
      super
    end

    def render(context)
      Jekyll::Convenience::footnote_html @id
    end
  end

  class StateOfTheRealmInferenceTag < Liquid::Tag
    def initialize(tag_name, premises, tokens)
      raise(SyntaxError.new("invalid premises")) if ['"', '<', '>'].any? { |c| premises.include?(c) }
      @premises = premises.strip unless premises.strip.empty?
      super
    end

    def render(context)
      Jekyll::Convenience::inference_html @premises
    end
  end

  class StateOfTheRealmEvidenceTag < Liquid::Block
    def render(context)
      context.stack do
        body = super

        StateOfTheRealmIds::check_finished

        "<span class=\"state-of-the-realm-evidence\"><hr>#{body}</span>"
      end
    end
  end

  class StateOfTheRealmPieceTag < Liquid::Block
    def initialize(tag_name, ref, tokens)
      raise(SyntaxError.new("invalid ref")) if ['"', '<', '>'].any? { |c| ref.include?(c) }
      @ref = ref.strip unless ref.strip.empty?

      @id = @ref.gsub(/[a-z\-]/i, '')

      StateOfTheRealmIds::evidence @id

      super
    end

    def render(context)
      context.stack do
        body = super
        "<span class=\"state-of-the-realm-piece-ref\">#{@ref}</span>: <span id=\"#{@ref}\" class=\"state-of-the-realm-piece-body\">#{body}</span>"
      end
    end
  end


  Liquid::Template.register_tag('fact',       Jekyll::StateOfTheRealmFactTag)
  Liquid::Template.register_tag('conjecture', Jekyll::StateOfTheRealmConjectureTag)
  Liquid::Template.register_tag('statement',  Jekyll::StateOfTheRealmStatementTag)
  Liquid::Template.register_tag('footnote',   Jekyll::StateOfTheRealmFootnoteTag)

  Liquid::Template.register_tag('inference',  Jekyll::StateOfTheRealmInferenceTag)

  Liquid::Template.register_tag('evidence',   Jekyll::StateOfTheRealmEvidenceTag)
  Liquid::Template.register_tag('piece',      Jekyll::StateOfTheRealmPieceTag)

  Jekyll::Hooks.register :site, :after_reset do |post|
    StateOfTheRealmIds::reset
  end
end
