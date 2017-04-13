module STARMAN
  class Npm < Package
    url 'https://registry.npmjs.org/npm/-/npm-4.4.4.tgz'
    sha256 'c63021c67ad86efa9b0d694c158168ec445cfa2b5ad54594ea2adfec180060c1'
    version '4.4.4'

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
