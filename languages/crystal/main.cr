require "db"

{% if flag?(:db_pg) %}
  require "pg"
{% else %}
  require "pq"
{% end %}

connection_string = ARGV[0]

def benchmark(&block) : Time::Span
  t1 = Time.now
  yield
  t2 = Time.now
  t2 - t1
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

  puts t1, t2, t3, t4, t5
end