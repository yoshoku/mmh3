# frozen_string_literal: true

RSpec.describe Mmh3 do
  describe '#hash32' do
    it { expect(described_class.hash32('Hello, world', 0)).to eq(1785891924) }
    it { expect(described_class.hash32('Hello, world', 10)).to eq(-172601702) }
  end

  describe '#hash128' do
    it { expect(described_class.hash128('Hello, world', 0)).to eq(158517598496188337575393694976300464500) }
    it { expect(described_class.hash128('Hello, world', 80)).to eq(30039177286814921195667057753583847313) }
  end

  describe '#hash128_x86' do
    it { expect(described_class.hash128_x86('Hello, world', 0)).to eq(253056019824187517714158156925852552360) }
    it { expect(described_class.hash128_x86('Hello, world', 7)).to eq(52510795136989075550025607058488316817) }
  end
end
