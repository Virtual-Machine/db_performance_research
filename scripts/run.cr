require "crust"

pool_size = "1"

if ARGV.size > 0
  pool_size = ARGV[0]
end

connection_string = "postgres://localhost:5432/test?prepared_statements=false"
connection_string += "&initial_pool_size=#{pool_size}&max_pool_size=#{pool_size}&max_idle_pool_size=#{pool_size}"
log = "results/log_file_#{pool_size}"
ruby_bin = "/usr/bin/ruby"

iterations = 10

iterations.times do |i|
  get_files "bin/" do |file|
    if (File.extname file) != ".rb"
      run_binary file, connection_string, log
    else
      run_script ruby_bin, file, log
    end
  end
  puts "Done iteration #{i + 1} of #{iterations}"
end
