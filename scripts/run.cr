require "crust"

connection_string = "postgres://localhost:5432/test?prepared_statements=false"
connection_string += "&initial_pool_size=1&max_pool_size=1&max_idle_pool_size=1"
log = "log_file"
ruby_bin = "/usr/bin/ruby"

10.times do
  get_files "bin/" do |file|
    if (File.extname file) != ".rb"
      run_binary file, connection_string, log
    else
      run_script ruby_bin, file, log
    end
  end
end
