# frozen_string_literal: true

# Return samples as a Hash with results indexed by name
instancer = lambda do
  {}.tap do |samples|
    SAMPLES_PATH.join('instances').glob('*.rb').sort.each do |path|
      path.basename('.rb').to_s.to_sym.tap do |key|
        samples[key] = lambda do
          self.instance_eval(Pathname.new(path).read, path.to_s, 1)
        end
      end
    end
  end.transform_values { |v| v.call.new }.to_h
end

Sham.config(FactoryStruct, File.basename(__FILE__, '.*').to_sym) do |c|
  c.attributes do
    # @formatter:off
    {
      instances: instancer.call
    }
    # @formatter:on
  end
end
