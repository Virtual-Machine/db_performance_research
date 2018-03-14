require "crust"
require "csv"

def colourize_name(name : String) : String
  case name
  when "crystal-pg", "crystal-pq"
    return "\033[0;33m#{name}\033[0m"
  when "crystal-libpq"
    return "\033[0;35m#{name}\033[0m"
  when "ruby"
    return "\033[0;31m#{name}\033[0m"
  when "go"
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

struct ResultSet
  property min_name, max_name, min_value, max_value, overall

  def initialize(@min_name : String, @max_name : String, @min_value : Float64, @max_value : Float64, @overall : Hash(String, Float64))
  end

  def print_results(name : Symbol)
    puts
    puts name
    puts "==================="
    res = [] of Tuple(String, Float64)
    @overall.each do |rec|
      res << rec
    end
    res.sort! { |x, y| x[1] <=> y[1] }
    res.each do |rec|
      name = colourize_name(rec[0])
      val = clean_float(rec[1])
      puts "#{val}  --  #{name}"
    end

    puts "DELTA Fastest Vs Slowest: #{res[-1][1] - res[0][1]}"
  end
end

def starting_set : ResultSet
  return ResultSet.new "", "", 0.0, 0.0, {"crystal-pg" => 0.0, "crystal-pq" => 0.0, "crystal-libpq" => 0.0, "go" => 0.0, "ruby" => 0.0, "c" => 0.0}
end

macro update_results(*index)
  {% for i in index %}
    results["q{{i}}"].overall[subject] += q{{i}}

    if results["q{{i}}"].min_name == ""
      results["q{{i}}"].min_name = subject
      results["q{{i}}"].max_name = subject
      results["q{{i}}"].min_value = q{{i}}
      results["q{{i}}"].max_value = q{{i}}
    else
      if results["q{{i}}"].min_value > q{{i}}
        results["q{{i}}"].min_name = subject
        results["q{{i}}"].min_value = q{{i}}
      elsif results["q{{i}}"].max_value < q{{i}}
        results["q{{i}}"].max_name = subject
        results["q{{i}}"].max_value = q{{i}}
      end
    end
  {% end %}
end

results = {
  "q1": starting_set,
  "q2": starting_set,
  "q3": starting_set,
  "q4": starting_set,
  "q5": starting_set,
}

get_files "results/" do |file|
  csv_data = CSV.parse(File.read(file))
  csv_data.each do |row|
    subject = row[0]
    q1 = row[1].to_f
    q2 = row[2].to_f
    q3 = row[3].to_f
    q4 = row[4].to_f
    q5 = row[5].to_f

    update_results 1, 2, 3, 4, 5
  end
end

results.each do |key, value|
  value.print_results key
end
