require 'tmpdir'
require 'fileutils'
require 'open3'

def root_path
  File.expand_path('../.', __FILE__)
end

def commit
  @commit ||= (
    ENV['TRAVIS_COMMIT'] || `git rev-parse --abbrev-ref HEAD`.chomp
  )
end

def platform
  @platform ||= begin
    platform_config = RbConfig::CONFIG['arch']
    case
      when platform_config.match('darwin')
        # clang -v (grab first line)
        #
        # Apple LLVM version 9.0.0 (clang-900.0.38)
        #
        compiler = ""
        Open3.popen3("clang -v") do |_stdin, _stdout, stderr, _wait_thread|
          first_line = ""
          while line = stderr.gets do; first_line = line; break; end
          compiler = first_line.scan(%r{^Apple LLVM version [\d]+.[\d]+.[\d]})
        end
        compiler_short = "clang-" + compiler[0].split(" ")[3]
        @platform = { arch_name: :darwin, compiler: compiler_short }
      when platform_config.match('linux')
        # gcc -v (grab last line)
        #
        # gcc version 6.3.0 20170516 (Debian 6.3.0-18)
        # gcc version 5.4.0 20160609 (Ubuntu 5.4.0-6ubuntu1~16.04.5)
        # gcc version 4.8.5 20150623 (Red Hat 4.8.5-16) (GCC)
        #
        compiler = ""
        Open3.popen3("gcc -v") do |_stdin, _stdout, stderr, _wait_thread|
          last_line = ""
          while line = stderr.gets do; last_line = line; end
          compiler = last_line.scan(%r{^gcc version [\d]+.[\d]+.[\d]})
        end
        compiler_short = "gcc-" + compiler[0].split(" ")[2]
        @platform = { arch_name: :linux, compiler: compiler_short }
      else
        raise RuntimeError, "Unsupported platform architecture detected"
    end
    @platform
  end
end

# copy build logs to source directory
def copy_logs(build_directory, label="")
  _build_directory = build_directory
  if _build_directory.nil? || _build_directory.empty?
    raise ArgumentError, "invalid build_directory specified: nil or empty"
  end

  _label = ""
  _label = "(#{label})" unless (label.nil? || label.empty?)

  printf "Copying log files #{_label}...\n"

  FileUtils.mkdir("#{root_path}/build_logs") unless Dir.exist?("#{root_path}/build_logs")
  _build_logs = Dir.glob("#{_build_directory}/gvm2/logs/*.log")

  # debug verbosity
  if ENV['GVM_DEBUG'] == '1'
    printf "  log file source directory: #{_build_directory}/gvm2/logs/\n"
    printf "  log file output directory: #{root_path}/build_logs/\n"
  end

  if _build_logs.count > 0
    printf "Log files found:\n"
    _build_logs.each_with_index { |f,i| printf("  [%3d] %s\n", i+1, f) }
  else
    printf "No log files found.\n"
    return
  end

  FileUtils.cp(_build_logs, "#{root_path}/build_logs")
end

# remove old build logs from source directory
def remove_logs(label="")
  _label = ""
  _label = "(#{label})" unless (label.nil? || label.empty?)

  printf "Removing old log files #{_label}...\n"

  _build_logs = Dir.glob("#{root_path}/build_logs/*.log")

  if _build_logs.count > 0
    printf "Log files found:\n"
    _build_logs.each_with_index { |f,i| printf("  [%3d] %s\n", i+1, f) }
  else
    printf "No log files found.\n"
    return
  end

  FileUtils.rm(_build_logs)
end

desc "Run simple tests"
task :default do
  remove_logs("task: default")

  Dir.mktmpdir('gvm-test') do |tmpdir|
    begin
      # install GVM in tmpdir, suppress updates to user shell config files
      system(<<-EOSH) || raise(SystemCallError, "system shell (bash) call failed")
        bash -c '
          export GVM_NO_UPDATE_PROFILE=1
          #{root_path}/binscripts/gvm-installer #{commit} #{tmpdir}
        '
      EOSH
      Dir.glob("#{tmpdir}/gvm2/tests/*_comment_test.sh").sort.each do |f|
        # filter out platform tests for current target
        next if platform()[:arch_name] == :darwin && File.basename(f).match("linux")
        next if platform()[:arch_name] == :linux && File.basename(f).match("darwin")
        if platform()[:arch_name] == :linux
          next if File.basename(f).match("darwin")
          # which gcc?
          next if platform()[:compiler].match("gcc-6") && File.basename(f).match("gcc-4")
        end
        # run test
        system(<<-EOSH) || raise(SystemCallError, "system shell (bash) call failed")
          bash -c '
            export SANDBOX="#{tmpdir}"
            source #{tmpdir}/gvm2/scripts/gvm
            builtin cd #{tmpdir}/gvm2/tests
            tf --text "#{f}"
          '
        EOSH
      end
    rescue SystemCallError => e
      raise e
    ensure
      copy_logs(tmpdir, "task: default")
    end
  end
end

desc "Run scenario tests"
task :scenario do
  remove_logs("task: scenario")

  Dir["#{root_path}/tests/scenario/*_comment_test.sh"].sort.each do |test|
    name = File.basename(test)
    puts "Running scenario #{name}..."
    Dir.mktmpdir('gvm-test') do |tmpdir|
      begin
        # install GVM in tmpdir, suppress updates to user shell config files
        system(<<-EOSH) || raise(SystemCallError, "system shell (bash) call failed")
          bash -c '
            export GVM_NO_UPDATE_PROFILE=1
            #{root_path}/binscripts/gvm-installer #{commit} #{tmpdir}
            export SANDBOX="#{tmpdir}"
            source #{tmpdir}/gvm2/scripts/gvm
            builtin cd #{tmpdir}/gvm2/tests/scenario
            tf --text "#{name}"
          '
        EOSH
      rescue SystemCallError => e
        raise e
      ensure
        copy_logs(tmpdir, "task: scenario")
      end
    end
  end
end
