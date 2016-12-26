module STARMAN
  class Bufrlib < Package
    url 'http://www.nco.ncep.noaa.gov/sib/decoders/BUFRLIB/BUFRLIB_v11-0-0.tar'
    sha256 'f8828216f1d523aae5cc34151153577dc8cead61b3df7b074f936776ec0069df'
    version '11.0.0'

    def install
      inreplace 'preproc.sh', {
        'cpp' => 'cpp -traditional-cpp',
        'ls *.F'  => 'ls ../*.F',
        'bufrlib.PRM' => '../bufrlib.PRM'
      }
      mkdir 'build' do
        cp ['../*.c', '../*.f', '../*.h'], '.'
        run '$CC -DUNDERSCORE -c `../preproc.sh` *.c'
        run '$FC -DUNDERSCORE -c modv*.f moda*.f `ls -1 *.f | grep -v "mod[av]_" | cut -d ":" -f 2`'
        run 'ar crv libbufr.a *.o'
      end
      mkdir_p inc
      mkdir_p lib
      cp 'build/bufrlib.h', inc
      cp 'build/libbufr.a', lib
    end
  end
end
