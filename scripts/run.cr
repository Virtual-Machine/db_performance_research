require "crust"

iterations = 10

iterations.times do |i|
  get_files "bin/" do |file|
    if (File.extname file) != ".rb"
      if (File.basename file) == "crystal-pg" || (File.basename file) == "crystal-pq"
        system "#{file} 1"
        system "#{file} 10"
      else
        system "#{file}"
      end
    else
      system "/usr/bin/ruby #{file}"
    end
  end
  puts "Done iteration #{i + 1} of #{iterations}"
end
