# frozen_string_literal: true

require 'mmh3/version'

# rubocop:disable Metrics/AbcSize, Metrics/BlockLength, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/ModuleLength, Metrics/PerceivedComplexity

# This module consists module functions that implement MurmurHash3.
# MurmurHash3 was written by Austin Appleby, and is placed in the public domain.
# The author hereby disclaims copyright to this source code.
module Mmh3
  module_function

  # Generate a 32-bit hash value.
  #
  # @example
  #   require 'mmh3'
  #
  #   puts Mmh3.hash32('Hello, world') # => 1785891924
  #
  # @param key [String] Key for hash value.
  # @param seed [Integer] Seed for hash value.
  #
  # @return [Integer] Returns hash value.
  def hash32(key, seed: 0)
    keyb = key.to_s.bytes
    key_len = keyb.size
    n_blocks = key_len / 4

    h = seed
    (0...n_blocks * 4).step(4) do |bstart|
      k = block32(keyb, bstart, 0)
      h ^= scramble32(k)
      h = rotl32(h, 13)
      h = (h * 5 + 0xe6546b64) & 0xFFFFFFFF
    end

    tail_id = n_blocks * 4
    tail_sz = key_len & 3

    k = 0
    k ^= keyb[tail_id + 2] << 16 if tail_sz >= 3
    k ^= keyb[tail_id + 1] <<  8 if tail_sz >= 2
    k ^= keyb[tail_id + 0]       if tail_sz >= 1

    h ^= scramble32(k) if tail_sz.positive?

    h = fmix32(h ^ key_len)

    if (h & 0x80000000).zero?
      h
    else
      -((h ^ 0xFFFFFFFF) + 1)
    end
  end

  # Generate a 128-bit hash value.
  #
  # @example
  #   require 'mmh3'
  #
  #   puts Mmh3.hash128('Hello, world') # => 87198040132278428547135563345531192982
  #
  # @param key [String] Key for hash value.
  # @param seed [Integer] Seed for hash value.
  # @param x64arch [Boolean] Flag indicating whether to generate hash value for x64 architecture.
  #
  # @return [Integer] Returns hash value.
  def hash128(key, seed: 0, x64arch: true)
    return hash128_x86(key, seed) if x64arch == false

    hash128_x64(key, seed)
  end

  # private

  def hash128_x64(key, seed = 0)
    keyb = key.to_s.bytes
    key_len = keyb.size
    n_blocks = key_len / 16

    h1 = seed
    h2 = seed
    c1 = 0x87c37b91114253d5
    c2 = 0x4cf5ad432745937f

    (0...n_blocks * 8).step(8) do |bstart|
      k1 = block64(keyb, bstart, 0)
      k2 = block64(keyb, bstart, 8)

      k1 = (k1 * c1) & 0xFFFFFFFFFFFFFFFF
      k1 = rotl64(k1, 31)
      k1 = (k1 * c2) & 0xFFFFFFFFFFFFFFFF
      h1 ^= k1

      h1 = rotl64(h1, 27)
      h1 = (h1 + h2) & 0xFFFFFFFFFFFFFFFF
      h1 = (h1 * 5 + 0x52dce729) & 0xFFFFFFFFFFFFFFFF

      k2 = (k2 * c2) & 0xFFFFFFFFFFFFFFFF
      k2 = rotl64(k2, 33)
      k2 = (k2 * c1) & 0xFFFFFFFFFFFFFFFF
      h2 ^= k2

      h2 = rotl64(h2, 31)
      h2 = (h2 + h1) & 0xFFFFFFFFFFFFFFFF
      h2 = (h2 * 5 + 0x38495ab5) & 0xFFFFFFFFFFFFFFFF
    end

    tail_id = n_blocks * 16
    tail_sz = key_len & 15

    k2 = 0
    k2 ^= keyb[tail_id + 14] << 48 if tail_sz >= 15
    k2 ^= keyb[tail_id + 13] << 40 if tail_sz >= 14
    k2 ^= keyb[tail_id + 12] << 32 if tail_sz >= 13
    k2 ^= keyb[tail_id + 11] << 24 if tail_sz >= 12
    k2 ^= keyb[tail_id + 10] << 16 if tail_sz >= 11
    k2 ^= keyb[tail_id +  9] <<  8 if tail_sz >= 10
    k2 ^= keyb[tail_id +  8]       if tail_sz >=  9

    if tail_sz > 8
      k2 = (k2 * c2) & 0xFFFFFFFFFFFFFFFF
      k2 = rotl64(k2, 33)
      k2 = (k2 * c1) & 0xFFFFFFFFFFFFFFFF
      h2 ^= k2
    end

    k1 = 0
    k1 ^= keyb[tail_id + 7] << 56 if tail_sz >= 8
    k1 ^= keyb[tail_id + 6] << 48 if tail_sz >= 7
    k1 ^= keyb[tail_id + 5] << 40 if tail_sz >= 6
    k1 ^= keyb[tail_id + 4] << 32 if tail_sz >= 5
    k1 ^= keyb[tail_id + 3] << 24 if tail_sz >= 4
    k1 ^= keyb[tail_id + 2] << 16 if tail_sz >= 3
    k1 ^= keyb[tail_id + 1] <<  8 if tail_sz >= 2
    k1 ^= keyb[tail_id]           if tail_sz >= 1

    if tail_sz > 0
      k1 = (k1 * c1) & 0xFFFFFFFFFFFFFFFF
      k1 = rotl64(k1, 31)
      k1 = (k1 * c2) & 0xFFFFFFFFFFFFFFFF
      h1 ^= k1
    end

    h1 ^= key_len
    h2 ^= key_len

    h1 = (h1 + h2) & 0xFFFFFFFFFFFFFFFF
    h2 = (h1 + h2) & 0xFFFFFFFFFFFFFFFF

    h1 = fmix64(h1)
    h2 = fmix64(h2)

    h1 = (h1 + h2) & 0xFFFFFFFFFFFFFFFF
    h2 = (h1 + h2) & 0xFFFFFFFFFFFFFFFF

    h2 << 64 | h1
  end

  def hash128_x86(key, seed = 0)
    keyb = key.to_s.bytes
    key_len = keyb.size
    n_blocks = key_len / 16

    h1 = seed
    h2 = seed
    h3 = seed
    h4 = seed
    c1 = 0x239b961b
    c2 = 0xab0e9789
    c3 = 0x38b34ae5
    c4 = 0xa1e38b93

    (0...n_blocks * 16).step(16) do |bstart|
      k1 = block32(keyb, bstart,  0)
      k2 = block32(keyb, bstart,  4)
      k3 = block32(keyb, bstart,  8)
      k4 = block32(keyb, bstart, 12)

      k1 = (k1 * c1) & 0xFFFFFFFF
      k1 = rotl32(k1, 15)
      k1 = (k1 * c2) & 0xFFFFFFFF
      h1 ^= k1

      h1 = rotl32(h1, 19)
      h1 = (h1 + h2) & 0xFFFFFFFF
      h1 = (h1 * 5 + 0x561ccd1b) & 0xFFFFFFFF

      k2 = (k2 * c2) & 0xFFFFFFFF
      k2 = rotl32(k2, 16)
      k2 = (k2 * c3) & 0xFFFFFFFF
      h2 ^= k2

      h2 = rotl32(h2, 17)
      h2 = (h2 + h3) & 0xFFFFFFFF
      h2 = (h2 * 5 + 0x0bcaa747) & 0xFFFFFFFF

      k3 = (k3 * c3) & 0xFFFFFFFF
      k3 = rotl32(k3, 17)
      k3 = (k3 * c4) & 0xFFFFFFFF
      h3 ^= k3

      h3 = rotl32(h3, 15)
      h3 = (h3 + h4) & 0xFFFFFFFF
      h3 = (h3 * 5 + 0x96cd1c35) & 0xFFFFFFFF

      k4 = (k4 * c4) & 0xFFFFFFFF
      k4 = rotl32(k4, 18)
      k4 = (k4 * c1) & 0xFFFFFFFF
      h4 ^= k4

      h4 = rotl32(h4, 13)
      h4 = (h4 + h1) & 0xFFFFFFFF
      h4 = (h4 * 5 + 0x32ac3b17) & 0xFFFFFFFF
    end

    tail_id = n_blocks * 16
    tail_sz = key_len & 15

    k4 = 0
    k4 ^= keyb[tail_id + 14] << 16 if tail_sz >= 15
    k4 ^= keyb[tail_id + 13] <<  8 if tail_sz >= 14
    k4 ^= keyb[tail_id + 12]       if tail_sz >= 13

    if tail_sz > 12
      k4 = (k4 * c4) & 0xFFFFFFFF
      k4 = rotl32(k4, 18)
      k4 = (k4 * c1) & 0xFFFFFFFF
      h4 ^= k4
    end

    k3 = 0
    k3 ^= keyb[tail_id + 11] << 24 if tail_sz >= 12
    k3 ^= keyb[tail_id + 10] << 16 if tail_sz >= 11
    k3 ^= keyb[tail_id +  9] <<  8 if tail_sz >= 10
    k3 ^= keyb[tail_id +  8]       if tail_sz >=  9

    if tail_sz > 8
      k3 = (k3 * c3) & 0xFFFFFFFF
      k3 = rotl32(k3, 17)
      k3 = (k3 * c4) & 0xFFFFFFFF
      h3 ^= k3
    end

    k2 = 0
    k2 ^= keyb[tail_id +  7] << 24 if tail_sz >=  8
    k2 ^= keyb[tail_id +  6] << 16 if tail_sz >=  7
    k2 ^= keyb[tail_id +  5] <<  8 if tail_sz >=  6
    k2 ^= keyb[tail_id +  4]       if tail_sz >=  5

    if tail_sz > 4
      k2 = (k2 * c2) & 0xFFFFFFFF
      k2 = rotl32(k2, 16)
      k2 = (k2 * c3) & 0xFFFFFFFF
      h2 ^= k2
    end

    k1 = 0
    k1 ^= keyb[tail_id +  3] << 24 if tail_sz >=  4
    k1 ^= keyb[tail_id +  2] << 16 if tail_sz >=  3
    k1 ^= keyb[tail_id +  1] <<  8 if tail_sz >=  2
    k1 ^= keyb[tail_id]            if tail_sz >=  1

    if tail_sz > 0
      k1 = (k1 * c1) & 0xFFFFFFFF
      k1 = rotl32(k1, 15)
      k1 = (k1 * c2) & 0xFFFFFFFF
      h1 ^= k1
    end

    h1 ^= key_len
    h2 ^= key_len
    h3 ^= key_len
    h4 ^= key_len

    h1 = (h1 + h2) & 0xFFFFFFFF
    h1 = (h1 + h3) & 0xFFFFFFFF
    h1 = (h1 + h4) & 0xFFFFFFFF
    h2 = (h1 + h2) & 0xFFFFFFFF
    h3 = (h1 + h3) & 0xFFFFFFFF
    h4 = (h1 + h4) & 0xFFFFFFFF

    h1 = fmix32(h1)
    h2 = fmix32(h2)
    h3 = fmix32(h3)
    h4 = fmix32(h4)

    h1 = (h1 + h2) & 0xFFFFFFFF
    h1 = (h1 + h3) & 0xFFFFFFFF
    h1 = (h1 + h4) & 0xFFFFFFFF
    h2 = (h1 + h2) & 0xFFFFFFFF
    h3 = (h1 + h3) & 0xFFFFFFFF
    h4 = (h1 + h4) & 0xFFFFFFFF

    h4 << 96 | h3 << 64 | h2 << 32 | h1
  end

  def block32(kb, bstart, offset)
    kb[bstart + offset + 3] << 24 |
    kb[bstart + offset + 2] << 16 |
    kb[bstart + offset + 1] <<  8 |
    kb[bstart + offset]
  end

  def block64(kb, bstart, offset)
    kb[2 * bstart + (7 + offset)] << 56 |
    kb[2 * bstart + (6 + offset)] << 48 |
    kb[2 * bstart + (5 + offset)] << 40 |
    kb[2 * bstart + (4 + offset)] << 32 |
    kb[2 * bstart + (3 + offset)] << 24 |
    kb[2 * bstart + (2 + offset)] << 16 |
    kb[2 * bstart + (1 + offset)] <<  8 |
    kb[2 * bstart + offset]
  end

  def rotl32(x, r)
    (x << r | x >> (32 - r)) & 0xFFFFFFFF
  end

  def rotl64(x, r)
    (x << r | x >> (64 - r)) & 0xFFFFFFFFFFFFFFFF
  end

  def scramble32(k)
    k = (k * 0xcc9e2d51) & 0xFFFFFFFF
    k = rotl32(k, 15)
    (k * 0x1b873593) & 0xFFFFFFFF
  end

  def fmix32(h)
    h ^= h >> 16
    h = (h * 0x85ebca6b) & 0xFFFFFFFF
    h ^= h >> 13
    h = (h * 0xc2b2ae35) & 0xFFFFFFFF
    h ^ (h >> 16)
  end

  def fmix64(h)
    h ^= h >> 33
    h = (h * 0xff51afd7ed558ccd) & 0xFFFFFFFFFFFFFFFF
    h ^= h >> 33
    h = (h * 0xc4ceb9fe1a85ec53) & 0xFFFFFFFFFFFFFFFF
    h ^ (h >> 33)
  end

  private_class_method :hash128_x64, :hash128_x86, :block32, :block64, :rotl32, :rotl64, :scramble32, :fmix32, :fmix64
end

# rubocop:enable Metrics/AbcSize, Metrics/BlockLength, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/ModuleLength, Metrics/PerceivedComplexity
