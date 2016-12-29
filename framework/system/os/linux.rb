module STARMAN
  class Linux < OS
    version do
      `lsb_release -r`.gsub(/^\D*/, '').chomp rescue nil
    end
    soname :so
    ld_library_path 'LD_LIBRARY_PATH'

    command :check_user do |name|
      `id -u #{name} 2>&1`
      $?.success?
    end
    command :check_group do |name|
      not `grep #{name} /etc/group`.empty?
    end
    command :create_user do |name, *options|
      CLI.report_notice "Create user #{CLI.blue name}."
      CLI.report_error "User #{CLI.red name} exists!" if check_user name
      args = []
      if options.include? :with_group
        args << '--user-group'
      else
        args << '--no-user-group'
      end
      if options.include? :with_home
        args << '--create-home'
      else
        args << '--no-create-home'
      end
      if options.include? :hide_login
        args << '--system --shell /bin/false'
      else
        args << '--shell bash'
      end
      res = `sudo useradd #{args.join(' ')} #{name}`
      CLI.report_error "Failed to create user #{CLI.red name}! See errors:\n#{res}" if not $?.success?
      res = `sudo passwd #{name}`
      CLI.report_error "Failed to set password for user #{CLI.red name}! See errors:\n#{res}" if not $?.success?
    end
    command :change_owner do |path, owner|
      CLI.report_notice "Change owner of #{CLI.blue path} to #{CLI.blue owner}."
      res = `sudo chown -R #{owner} #{path} 2>&1`
      CLI.report_error "Failed to change owner of #{CLI.red path} to #{CLI.red owner}! See errors:\n#{res}" if not $?.success?
    end
  end
end
