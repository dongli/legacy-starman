module STARMAN
  class Tensorflow < Package
    version '0.12.0rc1'

    label :compiler_agnostic
    label :external_binary
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

    if with_cuda?
      external_binary_on :mac do
        url 'https://storage.googleapis.com/tensorflow/mac/gpu/tensorflow_gpu-0.12.0rc1-py3-none-any.whl'
        sha256 ''
      end
    else
      external_binary_on :mac do
        url 'https://storage.googleapis.com/tensorflow/mac/cpu/tensorflow-0.12.0rc1-py3-none-any.whl'
        sha256 '72c15e0777268abba4195a8ae711e0e189f2569f6aca3f1ede4e24613f07c133'
      end
    end

    if with_cuda?
      external_binary_on :ubuntu do
        url 'https://storage.googleapis.com/tensorflow/linux/gpu/tensorflow_gpu-0.12.0rc1-cp35-cp35m-linux_x86_64.whl'
        sha256 ''
      end
    else
      external_binary_on :ubuntu do
        url 'https://storage.googleapis.com/tensorflow/linux/cpu/tensorflow-0.12.0rc1-cp35-cp35m-linux_x86_64.whl'
        sha256 'a41bc3546fbc9adfb2fa8f092cf287ae63362314ef088ead4f4da2ad9cec357d'
      end
    end

    def install
      # Use virtualenv to install.
      run 'pip3', 'install', '--upgrade', 'virtualenv'
      FileUtils.mkdir_p prefix
      run 'virtualenv', '--system-site-packages', prefix
      System::Shell.append_source_file "#{bin}/activate"
      run 'pip3', 'install', '--upgrade', 'ipython'
      run 'pip3', 'install', '--upgrade', external_binary_path
      System::Shell.clean_source_files
    end
  end
end
