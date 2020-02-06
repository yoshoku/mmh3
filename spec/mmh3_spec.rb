# frozen_string_literal: true

RSpec.describe Mmh3 do
  describe '#hash32' do
    it { expect(Mmh3.hash32('Hello, world', 0)).to eq(1785891924) }
    it { expect(Mmh3.hash32('Hello, world', 10)).to eq(-172601702) }
  end
end
