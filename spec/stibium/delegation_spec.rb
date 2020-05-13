# frozen_string_literal: true

sham!(:samples).results.each do |sample_name, results|
  sham!(:samples).instances.fetch(sample_name).tap do |instance|
    results.each_key do |method_name|
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

          # rubocop:disable Layout/LineLength
          it { expect(described_class.delegation[method_name]&.chomp).to eq(code) }
          # rubocop:enable Layout/LineLength
        end
      end
    end
  end
end

# testing real behavior ---------------------------------------------

autoload(:SecureRandom, 'securerandom')

sham!(:samples).instances.fetch(:fileutils_touch).tap do |sample|
  describe sample.class, :'stibium/delegation' do
    let(:subject) { sample }

    it { expect(subject).to respond_to(:touch) }

    tmpdir.join("rspec_#{SecureRandom.hex}").tap do |file|
      context "#touch(#{file.inspect})" do
        it { expect(subject.touch(file)).to eq([file.to_s]) }
      end
    end
  end
end
