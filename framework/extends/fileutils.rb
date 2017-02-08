require 'fileutils'

module FileUtils
  alias_method :old_mkdir_p, :mkdir_p
  def mkdir_p dir, options = {}, &block
    begin
      rm_rf dir, :secure => true if options[:force]
      options.delete :force
      old_mkdir_p dir, options
      work_in dir, &block if block_given?
    rescue Errno::EACCES => e
      STARMAN::CLI.report_error "Failed to create directory #{STARMAN::CLI.red dir}! Create it manually by using sudo, then back."
    end
  end

  alias_method :old_mkdir, :mkdir
  def mkdir dir, options = {}, &block
    begin
      rm_rf dir, :secure => true if options[:force]
      options.delete :force
      old_mkdir dir, options
      work_in dir, &block if block_given?
    rescue Errno::EACCES => e
      STARMAN::CLI.report_error "Failed to create directory #{STARMAN::CLI.red list}! Create it manually by using sudo, then back."
    end
  end

  alias_method :old_rm_r, :rm_r
  def rm_r pattern, options = {}
    old_rm_r Dir.glob(pattern), options
  end

  alias_method :old_rm_f, :rm_f
  def rm_f pattern, options = {}
    old_rm_f Dir.glob(pattern), options
  end

  alias_method :old_cp, :cp
  def cp src, dst, options = {}
    Array(src).each do |s|
      Dir.glob(s).each do |file|
        old_cp file, dst
      end
    end
  end

  alias_method :old_cp_r, :cp_r
  def cp_r src, dst, options = {}
    Array(src).each do |s|
      Dir.glob(s).each do |file|
        old_cp_r file, dst
      end
    end
  end

  alias_method :old_ln_sf, :ln_sf
  def ln_sf src, dst, options = {}
    begin
      old_ln_sf src, dst
    rescue Errno::EEXIST
    end
  end

  # New added methods

  def cd dir, *options
    if dir == :back
      chdir @@cd_dir_stack.last
      @@cd_dir_stack.pop
    else
      @@cd_dir_stack ||= []
      @@cd_dir_stack << pwd if not options.include? :not_record
      chdir dir
    end
  end

  def work_in dir
    STARMAN::CLI.report_error 'No work block is given!' if not block_given?
    STARMAN::CLI.report_error "Directory #{STARMAN::CLI.red dir} does not exist!" if not Dir.exist? dir
    cd dir
    yield
    cd :back
  end

  def append_file file_path, content = nil, &block
    dir = File.dirname file_path
    mkdir_p dir if not Dir.exist? dir
    if File.exist? file_path
      file = File.open file_path, 'a'
    else
      file = File.new file_path, 'w'
    end
    if block_given?
      content ||= ''
      yield content
    end
    file << content
    file.close
  end

  def write_file file_path, content = nil, &block
    dir = File.dirname file_path
    mkdir_p dir if not Dir.exist? dir
    file = File.new file_path, 'w'
    if block_given?
      content ||= ''
      yield content
    end
    file << content
    file.close
  end

  def inreplace file_paths, before = nil, after = nil, &block
    Array(file_paths).each do |file_path|
      content = File.read(file_path)
      if block_given?
        block.call content
      elsif before.class == Hash and not after
        before.each do |key, value|
          content.gsub! key, value
        end
      elsif before.class == String and after.class == String
        content.gsub! before, after
      end
      write_file file_path, content
    end
  end

  def delete_lines file_path, lines
    content = ''
    line = 0
    File.read(file_path).each_line do |line_content|
      line += 1
      next if lines.include? line
      content << line_content
    end
    File.open(file_path, 'w') do |file|
      file.write content
      file.close
    end
  end
end
