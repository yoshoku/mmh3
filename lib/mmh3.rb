# frozen_string_literal: true

require 'mmh3/version'

# This module consists module functions that implement MurmurHash3.
# MurmurHash3 was written by Austin Appleby, and is placed in the public domain.
# The author hereby disclaims copyright to this source code.
module Mmh3
  module_function

  # Generate a 32-bit hash value.
  #
  # @param key [String] Key for hash value.
  # @param seed [Integer] Seed for hash value.
  #
  # @return [Integer] Returns hash value.
  def hash32(key, seed = 0)
    keyb = key.to_s.bytes
    key_len = keyb.size
    n_blocks = key_len / 4

    h = seed
    (0...n_blocks * 4).step(4) do |bstart|
      k = keyb[bstart + 3] << 24 | keyb[bstart + 2] << 16 | keyb[bstart + 1] << 8 | keyb[bstart + 0]
      h ^= scramble32(k)
      h = rotl32(h, 13)
      h = (h * 5 + 0xe6546b64) & 0xFFFFFFFF
    end

    tail_id = n_blocks * 4
    tail_sz = key_len & 3

    k = 0
    k ^= keyb[tail_id + 2] << 16 if tail_sz >= 3
    k ^= keyb[tail_id + 1] << 8 if tail_sz >= 2
    k ^= keyb[tail_id + 0] if tail_sz >= 1
    h ^= scramble32(k) if tail_sz.positive?

    h = fmix32(h ^ key_len)

    if (h & 0x80000000).zero?
      h
    else
      -((h ^ 0xFFFFFFFF) + 1)
    end
  end

  # Generate a 128-bit hash value for x64 architecture.
  #
  # @param key [String] Key for hash value.
  # @param seed [Integer] Seed for hash value.
  #
  # @return [Integer] Returns hash value.
  def hash128(key, seed = 0)
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

  # private

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

  private_class_method :block64, :rotl32, :rotl64, :scramble32, :fmix32, :fmix64
end
