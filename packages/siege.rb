module STARMAN
  class Siege < Package
    homepage 'https://github.com/JoeDog/siege'
    url 'https://github.com/JoeDog/siege/archive/RELEASE_4-0-2-MAY-20-2016.tar.gz'
    sha256 'd2bcedf853d28ae7e6dc5e4eeedcebbef6a695a5c4c08822a8292b80dc674dbb'
    version '4.0.2'
    filename 'siege-4.0.2.tar.gz'

    label :compiler_agnostic

    depends_on :automake if needs_build?
    depends_on :openssl

    def install
      args = %W[
        --prefix=#{prefix}
        --with-ssl=#{Openssl.prefix}
      ]
      run 'utils/bootstrap'
      run './configure', *args
      run 'make'
      run 'make', 'install'
    end
  end
end
