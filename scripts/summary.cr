require "crust"
require "csv"

struct ResultSet
  property min_name, max_name, min_value, max_value, overall

  def initialize(@min_name : String, @max_name : String, @min_value : Float64, @max_value : Float64, @overall : Hash(String, Float64))
  end
end

def starting_set : ResultSet
  return ResultSet.new "", "", 0.0, 0.0, {"crystal-pg" => 0.0, "crystal-pq" => 0.0, "go" => 0.0, "ruby" => 0.0, "c" => 0.0}
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

pp results

results.each do |key, value|
  fastest = ""
  v = 1000
  slowest = ""
  v2 = 0
  value.overall.each do |key2, value2|
    if value2 < v
      fastest = key2
      v = value2
    end
    if value2 > v2
      slowest = key2
      v2 = value2
    end
  end
  cry_cur = (results[key].overall["crystal-pg"] + results[key].overall["crystal-pq"]) / 2
  puts "fastest at #{key} is #{fastest} with\n #{v}"
  puts "crystal at #{key} =\n #{cry_cur}"
  puts "slowest at #{key} is #{slowest} with\n #{v2}"
  puts ""
end
