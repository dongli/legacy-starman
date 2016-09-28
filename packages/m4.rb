module STARMAN
  class M4 < Package
    homepage 'https://www.gnu.org/software/m4'
    url 'http://ftp.gnu.org/gnu/m4/m4-1.4.17.tar.gz'
    sha256 '3ce725133ee552b8b4baca7837fb772940b25e81b2a9dc92537aeaf733538c9e'
    version '1.4.17'

    label :compiler_agnostic

    def install
      run './configure', '--disable-dependency-tracking', "--prefix=#{prefix}"
      run 'make'
      run 'make', 'install'
    end
  end
end
