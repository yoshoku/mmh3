# frozen_string_literal: true

require_relative 'lib/mmh3/version'

Gem::Specification.new do |spec|
  spec.name          = 'mmh3'
  spec.version       = Mmh3::VERSION
  spec.authors       = ['yoshoku']
  spec.email         = ['yoshoku@outlook.com']

  spec.summary       = 'A pure Ruby implementation of MurmurHash3'
  spec.description   = 'A pure Ruby implementation of MurmurHash3'
  spec.homepage      = 'https://github.com/yoshoku/mmh3'
  spec.license       = 'MIT'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/yoshoku/mmh3'
  spec.metadata['changelog_uri'] = 'https://github.com/yoshoku/mmh3/blob/main/CHANGELOG.md'
  spec.metadata['documentation_uri'] = 'https://rubydoc.info/gems/mmh3'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
  spec.metadata['rubygems_mfa_required'] = 'true'
end
