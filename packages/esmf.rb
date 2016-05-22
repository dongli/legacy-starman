module STARMAN
  class Esmf < Package
    homepage 'https://earthsystemcog.org/projects/esmf/'
    url 'http://www.earthsystemmodeling.org/esmf_releases/public/ESMF_6_3_0rp1/esmf_6_3_0rp1_src.tar.gz'
    sha256 '89d9466fec099f375ec2182efd80af79e2ef6d486cdd51d5e18e9ab77b98dc1f'
    version '6.3.0rp1'
    language :c, :fortran

    option :use_pio, {
      :desc => 'Choose to use PIO library.',
      :accept_value => { :boolean => true }
    }

    depends_on :lapack
    depends_on :netcdf
    depends_on :pio if use_pio?

    def install

    end
  end
end
