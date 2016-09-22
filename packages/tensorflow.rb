module STARMAN
  class Tensorflow < Package
    url 'https://github.com/tensorflow/tensorflow/archive/v0.10.0.tar.gz'
    sha256 'f32df04e8f7186aaf6723fc5396733b2f6c2fd6fe4a53a54a68b80f3ec855680'
    version '0.10.0'
    filename 'tensorflow-0.10.0.tar.gz'

    label :system_conflict

    option 'with-gcp', {
      desc: 'Use Google Cloud Platform support.',
      accept_value: { boolean: false }
    }

    option 'with-cuda', {
      desc: 'Build with GPU support.',
      accept_value: { boolean: false }
    }

    depends_on :python3

    def binary_url
      if with_cuda?
        case OS.type
        when :ubuntu
          'https://storage.googleapis.com/tensorflow/linux/gpu/tensorflow-0.10.0-cp35-cp35m-linux_x86_64.whl'
        when :mac
          'https://storage.googleapis.com/tensorflow/mac/gpu/tensorflow-0.10.0-py3-none-any.whl'
        end
      else
        case OS.type
        when :ubuntu
          'https://storage.googleapis.com/tensorflow/linux/cpu/tensorflow-0.10.0-cp35-cp35m-linux_x86_64.whl'
        when :mac
        'https://storage.googleapis.com/tensorflow/mac/cpu/tensorflow-0.10.0-py3-none-any.whl'
        end
      end
    end

    def install
      # Use virtualenv to install.
      run 'pip3', 'install', 'virtualenv'
      FileUtils.mkdir_p prefix
      run 'virtualenv', '--system-site-packages', prefix
      System::Shell.append_source_file "#{bin}/activate"
      run 'pip3', 'install', '--upgrade', 'ipython'
      run 'pip3', 'install', '--upgrade', binary_url
      System::Shell.clean_source_files
    end
  end
end
