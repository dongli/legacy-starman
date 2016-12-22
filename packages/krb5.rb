module STARMAN
  class Krb5 < Package
    url 'https://web.mit.edu/kerberos/dist/krb5/1.15/krb5-1.15.tar.gz'
    sha256 'fd34752774c808ab4f6f864f935c49945f5a56b62240b1ad4ab1af7b4ded127c'
    version '1.15'

    depends_on :byacc if needs_build?

    def install
      work_in 'src' do
        run './configure', "--prefix=#{prefix}"
        run 'make'
        run 'make', 'check'
        run 'make', 'install'
      end
    end
  end
end
