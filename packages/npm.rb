module STARMAN
  class Npm < Package
    url 'https://registry.npmjs.org/npm/-/npm-3.10.9.tgz'
    sha256 'fb0871b1aebf4b74717a72289fade356aedca83ee54e7386e38cb51874501dd6'
    version '3.10.9'

    label :compiler_agnostic

    depends_on :nodejs

    def install
      args = %W[
        --prefix=#{prefix}
      ]
      run './configure', *args
      run 'make', 'install'
    end
  end
end
