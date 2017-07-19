module STARMAN
  class Fox < Package
    homepage 'http://homepages.see.leeds.ac.uk/~earawa/FoX/'
    url 'http://homepages.see.leeds.ac.uk/~earawa/FoX/source/FoX-4.1.2.tar.gz'
    sha256 '3b749138229e7808d0009a97e2ac47815ad5278df6879a9cc64351a7921ba06f'
    version '4.1.2'
    language :fortran

    option 'with-wxml', {
      desc: 'Compile wxml subsystem (for XML output)',
      accept_value: { boolean: true }
    }

    option 'with-wcml', {
      desc: 'Compile wcml subsystem (for CML output)',
      accept_value: { boolean: true }
    }

    option 'with-wkml', {
      desc: 'Compile wkml subsystem (for KML output)',
      accept_value: { boolean: true }
    }

    option 'with-sax', {
      desc: 'Compile SAX parser',
      accept_value: { boolean: true }
    }

    option 'with-dom', {
      desc: 'Compile dom subsystem (for DOM output)',
      accept_value: { boolean: true }
    }

    option 'with-dummy', {
      desc: 'Compile only dummy interfaces',
      accept_value: { boolean: true }
    }

    def install
      args = ["--prefix=#{prefix}"]
      args << '--enable-wxml' if with_wxml?
      args << '--enable-wcml' if with_wcml?
      args << '--enable-wkml' if with_wkml?
      args << '--enable-sax' if with_sax?
      args << '--enable-dom' if with_dom?
      args << '--enable-dummy' if with_dummy?

      run './configure', *args
      run 'make'
      run 'make', 'check' unless skip_test?
      run 'make', 'install'
    end
  end
end
