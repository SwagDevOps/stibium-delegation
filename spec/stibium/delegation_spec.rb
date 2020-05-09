# frozen_string_literal: true

autoload(:Pathname, 'pathname')
autoload(:SecureRandom, 'securerandom')

sham!(:samples).instances.fetch(:greeter).tap do |greeter|
  describe greeter, :'stibium/delegation' do
    let(:subject) { greeter }

    it { expect(subject).to respond_to(:hello) }
    it { expect(subject).to respond_to(:goodbye) }
  end
end

sham!(:samples).instances.fetch(:class_method).tap do |sample|
  describe sample, :'stibium/delegation' do
    let(:subject) { sample }

    it { expect(subject).to respond_to(:class_method) }
    it { expect(subject.__send__(:inner_class)).to respond_to(:new) }
  end
end

sham!(:samples).instances.fetch(:fileutils_touch).tap do |sample|
  describe sample, :'stibium/delegation' do
    let(:subject) { sample }

    it { expect(subject).to respond_to(:touch) }

    tmpdir.join("rspec_#{SecureRandom.hex}").tap do |file|
      context "#touch(#{file.inspect})" do
        it { expect(subject.touch(file)).to eq([file.to_s]) }
      end
    end
  end
end

sham!(:samples).instances.fetch(:sample_1).tap do |sample|
  describe sample, :'stibium/delegation' do
    let(:subject) { sample }

    it { expect(subject).to respond_to(:sample) }
  end
end
