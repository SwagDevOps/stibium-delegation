# frozen_string_literal: true

# constants ---------------------------------------------------------
describe Stibium::Delegation, :'stibium/delegation' do
  [ # @formatter:off
    :Errors,
    :Inspection,
    :Methodifier,
    :ReflectionClass,
    :VERSION,
  ].each do |const_name| # @formatter:on
    it { expect(described_class).to be_const_defined(const_name) }
  end
end

# samples -----------------------------------------------------------
sham!(:samples).results.each do |sample_name, results|
  sham!(:samples).instances.fetch(sample_name).tap do |instance|
    results.to_a.reject { |v| v.fetch(1) =~ /^(protected|private)\s/ }.to_h.each_key do |method_name|
      describe instance.class, :'stibium/delegation', :methods do
        let(:subject) { instance }

        it { expect(subject).to respond_to(method_name) }
      end
    end

    describe instance.class, :'stibium/delegation', :results do
      results.each do |method_name, method_code|
        context ".delegation[#{method_name.inspect}]" do
          let(:described_class) { instance.class }
          let(:code) { method_code.chomp }

          it { expect(described_class.delegation[method_name]&.chomp).to eq(code) }
        end
      end
    end
  end
end

# testing real behavior ---------------------------------------------
sham!(:samples).instances.fetch(:fileutils_touch).tap do |sample|
  describe sample.class, :'stibium/delegation' do
    let(:subject) { sample }

    it { expect(subject).to respond_to(:touch) }

    sham!(:utils).mktemp.call(path: tmpdir, verbose: true, dry_run: true).tap do |file|
      context "#touch(#{file.inspect})" do
        before(:each) do
          autoload(:FileUtils, 'fileutils')

          FileUtils.mkdir_p(file.dirname)
        end

        it { expect(subject.touch(file)).to eq([file.to_s]) }
      end
    end
  end
end

# failure with inspection on protected method -----------------------
sham!(:samples).instances.fetch(:empty).tap do |sample|
  describe sample.class, :'stibium/delegation' do
    let(:described_class) { sample.class }
    let(:delegation_type) { described_class.__send__(:status_class) }

    context '.delegate(:failed?, to: :"@status") { delegation_type } ' do
      [ # @formatter:off
        RuntimeError,
        Stibium::Delegation::Errors::NoPublicMethodError,
      ].each do |error_class| # @formatter:on
        it do
          expect do
            described_class.__send__(:delegate, :failed?, to: :'@status', & -> { delegation_type })
          end.to raise_error(error_class, /method `failed\?' for #<Class:.*> is not a public instance method/)
        end
      end
    end
  end
end
