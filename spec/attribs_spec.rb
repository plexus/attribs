RSpec.describe Attribs do
  subject { Class.new.instance_exec(args) {|args| include Attribs.new(*args) } }
  let(:args) { [:foo, bar: 3] }

  let(:attributes_module) do
    subject.included_modules.detect do |mod|
      mod.instance_of?(described_class)
    end
  end

  describe '#initialize' do
    it 'should store defaults' do
      expect(attributes_module.defaults).to eql(bar: 3)
    end

    it 'should store attribute names' do
      expect(attributes_module.names).to eql [:foo, :bar]
    end

    context 'without defaults' do
      let(:args) { [:foo, :bar] }

      it 'should have no defaults' do
        expect(attributes_module.defaults).to eql({})
      end
    end

    context 'with a name given both with and without default' do
      let(:args) { [:foo, foo: 3] }

      it 'should only store the name once' do
        expect(attributes_module.names).to eql([:foo])
      end
    end
  end

  describe '#included' do
    it 'should have a hash-based constructor' do
      expect(subject.new(foo: 3, bar: 4).bar).to equal 4
    end

    it 'should have defaults constructor' do
      expect(subject.new(foo: 3).bar).to equal 3
    end

    it 'should allow updating through with' do
      expect(subject.new(foo: 3).with(foo: 4).to_h).to eql(foo: 4, bar: 3)
    end

    it 'should add an #append_to method' do
      expect(subject.new(foo: [6]).append_to(:foo, 7, 8).foo).to eql [6, 7, 8]
    end

    context 'with all defaults' do
      subject { Class.new { include Attribs.new(foo: 5, bar: 3) } }

      it 'should be able to construct without arguments' do
        expect(subject.new.to_h).to eql(foo: 5, bar: 3)
      end
    end

    context 'without any defaults' do
      subject { Class.new { include Attribs.new(:foo, :bar) } }

      it 'should allow setting all attributes' do
        expect(subject.new(foo: 5, bar: 6).bar).to equal 6
      end

      it 'should expect all attributes' do
        expect { subject.new(foo: 5) }.to raise_exception(Anima::Error, /missing: \[:bar\], unknown: \[\]/)
      end
    end
  end

  describe '#add' do
    subject { Class.new(super()) { include attributes.add(baz: 7, bar: 4) } }

    it 'should make the new attributes available' do
      expect(subject.new(foo: 3, baz: 6).baz).to equal 6
    end

    it 'should make the old attributes available' do
      expect(subject.new(foo: 3, baz: 6).foo).to equal 3
    end

    it 'should take new default values' do
      expect(subject.new(foo: 3, baz: 6).bar).to equal 4
    end

    it 'should make sure attribute names are uniq' do
      expect(subject.attributes.names.length).to equal 3
    end

    context 'without any defaults' do
      subject { Class.new(super()) { include attributes.add(:bax) } }

      it 'should allow setting all attributes' do
        expect(subject.new(foo: 5, bar: 6, bax: 7).bax).to equal 7
      end

      it 'should expect all attributes' do
        expect { subject.new(foo: 5, bar: 6) }.to raise_exception(Anima::Error, /missing: \[:bax\], unknown: \[\]/)
      end
    end
  end

  describe '#remove' do
    context 'when removing an attribute with a default' do
      subject { Class.new(super()) { include attributes.remove(:bar) } }

      it 'should still recognize attributes that were kept' do
        expect(subject.new(foo: 2).foo).to equal 2
      end

      it 'should no longer recognize the old attributes' do
        expect { subject.new(foo: 3, bar: 3).bar }.to raise_exception(Anima::Error, /missing: \[\], unknown: \[:bar\]/)
      end
    end

    context 'when removing an attribute without a default' do
      subject { Class.new(super()) { include attributes.remove(:foo) } }

      it 'should still recognize attributes that were kept' do
        expect(subject.new(bar: 2).bar).to equal 2
      end

      it 'should no longer recognize the old attributes' do
        expect { subject.new(foo: 3).foo }.to raise_exception(Anima::Error, /missing: \[\], unknown: \[:foo\]/)
      end

      it 'should keep the defaults' do
        expect(subject.new.bar).to equal 3
      end
    end
  end
end

RSpec.describe Attribs::InstanceMethods do
  let(:widget) do
    Class.new do
      include Attribs.new(:color, :size, options: {})
      def self.name ; 'Widget' ; end
    end
  end

  let(:widget_container) do
    Class.new do
      include Attribs.new(widgets: [])
      def self.name ; 'WidgetContainer' ; end
    end
  end

  let(:one_attr) do
    Class.new do
      include Attribs.new(:the_attr)
      def self.name ; 'OneAttr' ; end
    end
  end

  let(:fixed_width) do
    Class.new do
      def initialize(width)
        @width = width
      end

      def inspect
        "#" * @width
      end
    end
  end

  describe '#pp' do
    it 'should render correctly' do
      expect(widget_container.new(widgets: [
                                    widget.new(color: :green, size: 7),
                                    widget.new(color: :blue, size: 9, options: {foo: :bar})
                                  ]).pp).to eql "
WidgetContainer.new(
  widgets: [
    Widget.new(color: :green, size: 7),
    Widget.new(color: :blue, size: 9, options: {:foo=>:bar})
  ]
)
".strip
    end

    it 'should inline short arrays' do
      expect(widget_container.new(widgets: [
                                    fixed_width.new(23),
                                    fixed_width.new(22)
                                  ]).pp).to eql "WidgetContainer.new(widgets: [#######################, ######################])"
    end

    it 'should put longer arrays on multiple lines' do
      expect(widget_container.new(widgets: [
                                    fixed_width.new(23),
                                    fixed_width.new(23)
                                  ]).pp).to eql "WidgetContainer.new(\n  widgets: [\n    #######################,\n    #######################\n  ]\n)"
    end

    it 'should puts attributes on multiple lines if total length exceeds 50 chars' do
      expect(widget.new(color: fixed_width.new(18), size: fixed_width.new(18)).pp).to match /\n/
      expect(widget.new(color: fixed_width.new(18), size: fixed_width.new(17)).pp).to_not match /\n/
    end

    it 'should write out a readable representation of Time instanced' do
      expect(one_attr.new(the_attr: Time.parse("2016-02-22 09:41:29 +1100")).pp)
        .to eql 'OneAttr.new(the_attr: Time.parse("2016-02-22 09:41:29 +1100"))'
    end
  end

  describe '#append_to' do
    it 'should append to a named collection' do
      expect(widget_container.new(widgets: [:bar]).append_to(:widgets, :foo)).to eql widget_container.new(widgets: [:bar, :foo])
    end
  end

  describe '#initialize' do
    it 'should take hash-based args' do
      expect(widget_container.new(widgets: [:bar])).to eql widget_container.new.with(widgets: [:bar])
    end

    it 'should use defaults when available' do
      expect(widget.new(color: :blue, size: 3).options).to eql({})
    end
  end

  describe '#to_h_compact' do
    it 'should not show values that are identical to the defaults' do
      expect(widget.new(color: :red, size: 7).to_h_compact)
        .to eql({color: :red, size: 7})
    end

    it 'should include values that are equivalent but not identical' do
      expect(widget.new(color: :red, size: 7, options: {}).to_h_compact)
        .to eql({color: :red, size: 7, options: {}})
    end
  end

  describe '#with' do
    it 'should update specific attributes' do
      expect(widget.new(color: :red, size: 7).with(color: :blue))
        .to eql(widget.new(color: :blue, size: 7))
    end
  end
end
