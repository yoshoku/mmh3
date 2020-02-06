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

  def rotl32(x, r)
    (x << r | x >> (32 - r)) & 0xFFFFFFFF
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

  private_class_method :rotl32, :scramble32, :fmix32
end
