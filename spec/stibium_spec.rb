# frozen_string_literal: true

describe Stibium, :stibium do
  # @formatter:off
  [
    :Delegation,
  ].each do |k| # @formatter:on
    it { expect(described_class).to be_const_defined(k) }
  end
end
