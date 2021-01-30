# frozen_string_literal: true

RSpec.describe Mmh3 do
  describe '#hash32' do
    it { expect(described_class.hash32('Hello, world', seed: 0)).to eq(1785891924) }
    it { expect(described_class.hash32('Hello, world', seed: 10)).to eq(-172601702) }
  end

  describe '#hash128 (x64)' do
    it { expect(described_class.hash128('Hello, world', seed: 0)).to eq(158517598496188337575393694976300464500) }
    it { expect(described_class.hash128('Hello, world', seed: 80)).to eq(30039177286814921195667057753583847313) }
    it { expect(described_class.hash128('Hello, world. Hello, world. Hello, world.', seed: 10)).to eq(9261380712901568808277265119757985890) }
  end

  describe '#hash128 (x86)' do
    it { expect(described_class.hash128('Hello, world', seed: 0, x64arch: false)).to eq(253056019824187517714158156925852552360) }
    it { expect(described_class.hash128('Hello, world', seed: 7, x64arch: false)).to eq(52510795136989075550025607058488316817) }
    it { expect(described_class.hash128('Hello, world. Hello, world. Hello, world.', seed: 10, x64arch: false)).to eq(226892773628257154411244924604649453748) }
    it { expect(described_class.hash128('heelloo, world!', seed: 9, x64arch: false)).to eq(275876218145385640994298123654585548801) }
  end
end
