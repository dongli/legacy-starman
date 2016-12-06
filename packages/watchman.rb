module STARMAN
  class Watchman < Package
    homepage 'https://github.com/facebook/watchman'
    url 'https://github.com/facebook/watchman/archive/v4.7.0.tar.gz'
    sha256 '77c7174c59d6be5e17382e414db4907a298ca187747c7fcb2ceb44da3962c6bf'
    version '4.7.0'
    filename 'watchman-4.7.0.tar.gz'

    label :compiler_agnostic

    option :'with-python', {
      desc: 'Build with Python support.',
      accept_value: { boolean: false }
    }

    depends_on :autoconf if needs_build?
    depends_on :automake if needs_build?
    depends_on :pcre

    def install
      args = %W[
        --prefix=#{prefix}
        --disable-dependency-tracking
        --without-python
        --with-pcre='#{Pcre.bin}/pcre-config'
      ]
      run './autogen.sh'
      run './configure', *args
      run 'make'
      run 'make', 'install'
    end
  end
end
