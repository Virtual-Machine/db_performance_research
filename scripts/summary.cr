require "crust"
require "pg"
require "yaml"

# ========
# Helpers
# ========

def colourize_name(name : String) : String
  case name
  when "crystal-pg-1", "crystal-pq-1", "crystal-pg-10", "crystal-pq-10"
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

query_descriptions = YAML.parse File.read "sql/descriptions.yml"

connection_string = "postgres://localhost:5432/test?prepared_statements=false&initial_pool_size=1&max_pool_size=1&max_idle_pool_size=1"
pool_size = "1"

DB.open connection_string do |db|
  puts "Total in Seconds"
  db.query "select imp_name, sum(seconds) As TotalSeconds from results group by imp_name order by sum(seconds);" do |rs|
    rs.each do
      name = rs.read(String)
      total = rs.read(PG::Numeric)

      puts "  #{total.to_f}\t#{colourize_name(name)}"
    end
  end

  puts "\n#{query_descriptions["q1"]} in Seconds Averaged"
  db.query "select imp_name, avg(seconds) As AvgSeconds from results where test = 't1' group by imp_name order by avg(seconds);" do |rs|
    rs.each do
      name = rs.read(String)
      total = rs.read(PG::Numeric)

      puts "  #{total.to_f}\t#{colourize_name(name)}"
    end
  end
  puts

  puts "\n#{query_descriptions["q2"]} in Seconds Averaged"
  db.query "select imp_name, avg(seconds) As AvgSeconds from results where test = 't2' group by imp_name order by avg(seconds);" do |rs|
    rs.each do
      name = rs.read(String)
      total = rs.read(PG::Numeric)

      puts "  #{total.to_f}\t#{colourize_name(name)}"
    end
  end

  puts "\n#{query_descriptions["q3"]} in Seconds Averaged"
  db.query "select imp_name, avg(seconds) As AvgSeconds from results where test = 't3' group by imp_name order by avg(seconds);" do |rs|
    rs.each do
      name = rs.read(String)
      total = rs.read(PG::Numeric)

      puts "  #{total.to_f}\t#{colourize_name(name)}"
    end
  end

  puts "\n#{query_descriptions["q4"]} in Seconds Averaged"
  db.query "select imp_name, avg(seconds) As AvgSeconds from results where test = 't4' group by imp_name order by avg(seconds);" do |rs|
    rs.each do
      name = rs.read(String)
      total = rs.read(PG::Numeric)

      puts "  #{total.to_f}\t#{colourize_name(name)}"
    end
  end

  puts "\n#{query_descriptions["q5"]} in Seconds Averaged"
  db.query "select imp_name, avg(seconds) As AvgSeconds from results where test = 't5' group by imp_name order by avg(seconds);" do |rs|
    rs.each do
      name = rs.read(String)
      total = rs.read(PG::Numeric)

      puts "  #{total.to_f}\t#{colourize_name(name)}"
    end
  end

  puts "\n#{query_descriptions["q6"]} in Seconds Averaged"
  db.query "select imp_name, avg(seconds) As AvgSeconds from results where test = 't6' group by imp_name order by avg(seconds);" do |rs|
    rs.each do
      name = rs.read(String)
      total = rs.read(PG::Numeric)

      puts "  #{total.to_f}\t#{colourize_name(name)}"
    end
  end
end
