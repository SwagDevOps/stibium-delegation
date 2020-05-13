# frozen_string_literal: true

autoload(:Pathname, 'pathname')

# rubocop:disable Layout/LineLength

# Return samples as a Hash with results indexed by name -------------
instancer = lambda do
  {}.tap do |samples|
    SAMPLES_PATH.glob('*/sample.rb').sort.each do |path|
      path.dirname.basename.to_s.to_sym.tap do |key|
        samples[key] = lambda do
          self.instance_eval(Pathname.new(path).read, path.to_s, 1).tap do |klass|
            Sampler.new(path.dirname.basename).call(klass)
          end
        end
      end
    end
  end.transform_values { |v| v.call.new }.to_h
end

# Return results as a Hash with results indexed by name -------------
resulter = lambda do
  autoload(:YAML, 'yaml')

  {}.tap do |samples|
    SAMPLES_PATH.glob('*/result.yml').sort.each do |path|
      path.dirname.basename.to_s.to_sym.tap do |key|
        samples[key] = YAML.safe_load(Pathname.new(path).read)
      end
    end
  end.transform_keys(&:to_sym).transform_values { |v| v.transform_keys(&:to_sym) }.to_h
end

# Store samples and results to avoid indexation ---------------------
cache = lambda do
  @cache ||= { # @formatter:off
    instances: instancer.call,
    results: resulter.call,
  }
  # @formatter:on
end

# Sham --------------------------------------------------------------
Sham.config(FactoryStruct, File.basename(__FILE__, '.*').to_sym) do |c|
  c.attributes { cache.call }
end

# rubocop:enable Layout/LineLength
