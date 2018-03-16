require "crust"
require "csv"

# ========
# Helpers
# ========

def colourize_name(name : String) : String
  case name
  when "crystal-pg", "crystal-pq"
    return "\033[0;33m#{name}\033[0m"
  when "crystal-libpq"
    return "\033[0;35m#{name}\033[0m"
  when "ruby"
    return "\033[0;31m#{name}\033[0m"
  when "go-pg", "go-pgx"
    return "\033[0;34m#{name}\033[0m"
  when "c"
    return "\033[0;32m#{name}\033[0m"
  else
    return name
  end
end

def clean_float(res : Float64) : String
  return sprintf("%f", res)
end

# ========
# ResultSet  =   Container of aggregate stats for one test run
# ========

struct ResultSet
  property overall, counts

  def initialize(keys : Array(String))
    @overall = {} of String => Float64
    keys.each do |key|
      @overall[key] = 0.0
    end
  end

  def print_results(name : String)
    puts
    puts name
    puts "==================="
    res = [] of Tuple(String, Float64)
    @overall.each do |rec|
      res << rec
    end
    res.sort! { |x, y| x[1] <=> y[1] }

    res = res.reject { |x| x[1] == 0.0 }

    res.each do |rec|
      name = colourize_name(rec[0])
      val = clean_float(rec[1])
      puts "#{val}  --  #{name}"
    end

    puts "DELTA Fastest Vs Slowest: #{clean_float(res[-1][1] - res[0][1])}"
    puts "Overhead: #{clean_float((res[-1][1] / res[0][1]) * 100)}%"
  end
end

# ========
# generate a hash of String => ResultSet
# This hash contains a ResultSet per value column in the supplied CSV data
# ========

def generate_results(data : Array(Array(String))) : Hash(String, ResultSet)
  results = {} of String => ResultSet
  subjects = data.transpose[0].uniq
  data.each do |row|
    subject = row[0]
    values = row[1..-1]

    values.each_with_index do |val, i|
      q_index = "q#{i + 1}"
      q_val = val.to_f

      if !results.has_key?(q_index)
        results[q_index] = ResultSet.new subjects
      end

      cur_set = results[q_index]
      cur_set.overall[subject] += q_val
    end
  end
  results
end

# ========
# prints results of each resultset in result collection
# ========

def print_results(result_collection : Hash(String, ResultSet)) : Nil
  result_collection.each do |key, rs|
    rs.print_results key
  end
end

# ========
# for each file in results, generate results and report
# ========

get_files "results/" do |file|
  puts file
  csv_data = CSV.parse(File.read(file))

  results = generate_results csv_data
  print_results results
end
