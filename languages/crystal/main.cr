require "db"

driver = ""
{% if flag?(:db_pg) %}
  require "pg"
  driver = "pg"
{% else %}
  require "pq"
  driver = "pq"
{% end %}

connection_string = "postgres://localhost:5432/test?prepared_statements=false&initial_pool_size=1&max_pool_size=1&max_idle_pool_size=1"

if ARGV.size > 0
  connection_string = ARGV[0]
end

def benchmark(&block) : String
  t1 = Time.now
  yield
  t2 = Time.now
  diff = t2 - t1
  sprintf("%.6f", diff.total_seconds)
end

results = [] of Tuple(String, Float64)

query1 = File.read "sql/query1.sql"
query2 = File.read "sql/query2.sql"
query3 = File.read "sql/query3.sql"
query4 = File.read "sql/query4.sql"
query5 = File.read "sql/query5.sql"

DB.open connection_string do |db|
  t1 = benchmark do
    db.exec query1
  end

  t2 = benchmark do
    db.query query2 do |rs|
      rs.each do
        name = rs.read(String)
        age = rs.read(Int32)
      end
    end
  end

  t3 = benchmark do
    1000.times do |i|
      db.exec query3, ["a test #{i}", i]
    end
  end

  t4 = benchmark do
    db.query query4 do |rs|
      rs.each do
        name = rs.read(String)
        age = rs.read(Int32)
      end
    end
  end

  t5 = benchmark do
    1000.times do |i|
      db.query query5, [i] do |rs|
        rs.each do
          name = rs.read(String)
          age = rs.read(Int32)
        end
      end
    end
  end

  t6 = benchmark do
    channel = Channel(Nil).new(100)
    100.times do |i|
      proc = ->(j : Int32) do
        spawn do
          db.query query5, [j] do |rs|
            rs.each do
              name = rs.read(String)
              age = rs.read(Int32)
            end
          end
          channel.send(nil)
        end
      end
      proc.call(i)
    end
    100.times do
      channel.receive
    end
  end

  puts "crystal-#{driver},#{t1},#{t2},#{t3},#{t4},#{t5},#{t6}"
end
