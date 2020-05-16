# frozen_string_literal: true

autoload(:Pathname, 'pathname')
autoload(:SecureRandom, 'securerandom')
autoload(:FileUtils, 'fileutils')

# Make a temporary file name
#
# @see https://www.gnu.org/software/autogen/mktemp.html
mktemp = lambda do |path: Dir.tmpdir, prefix: nil, dry_run: false, verbose: false|
  maker = -> { Pathname.new(path).join([prefix, SecureRandom.hex].compact.join) }

  # @type [Pathname] res path to file or directory
  res = nil
  loop do
    next if (res = maker.call).exist?

    unless dry_run
      (verbose ? FileUtils::Verbose : FileUtils).tap do |fs|
        fs.mkdir_p(res.dirname, mode: 0o755)
        fs.touch(res)
      end
    end

    break
  end
  res
end

# Sham --------------------------------------------------------------
Sham.config(FactoryStruct, File.basename(__FILE__, '.*').to_sym) do |c|
  c.attributes do
    { # @formatter:off
      mktemp: mktemp
    } # @formatter:on
  end
end
