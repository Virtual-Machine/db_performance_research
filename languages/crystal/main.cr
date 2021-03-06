require "db"

driver = ""
connection_string = ""
pool_size = "1"

if ARGV.size > 0
  pool_size = ARGV[0]
end

{% if flag?(:db_pg) %}
  require "pg"
  driver = "pg"
  connection_string = "postgres://localhost:5432/test?initial_pool_size=#{pool_size}&max_pool_size=#{pool_size}&max_idle_pool_size=#{pool_size}"
{% else %}
  require "pq"
  driver = "pq"
  connection_string = "postgres://localhost:5432/test?prepared_statements=false&initial_pool_size=#{pool_size}&max_pool_size=#{pool_size}&max_idle_pool_size=#{pool_size}"
{% end %}

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
query6 = File.read "sql/query6.sql"
query7 = File.read "sql/query7.sql"

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

  t7 = benchmark do
    db.query query6 do |rs|
      rs.each do
        id = rs.read(Int32)
        f_id = rs.read(Int32)
        f_bool = rs.read(Bool)
        f_string = rs.read(String)
        f_decimal = rs.read(Float64)
        {% if flag?(:db_pg) %}
          f_date = rs.read
          f_time = rs.read
        {% else %}
          f_date = rs.read(PQ::Date)
          f_time = "..." #Not defined in rs using crystal-pq
        {% end %}
      end
    end
  end

  t8 = benchmark do
    db.query query7 do |rs|
      sum = 0.to_i64
      rs.each do
        f_id = rs.read(Int32)
        sum += f_id
      end
      if sum != 2249638468
        raise Exception.new "Invalid sum, something went wrong"
      end
    end
  end

  now = Time.now
  db.exec "insert into results values ($1, $2, $3, $4)", ["crystal-#{driver}-#{pool_size}", now, "t1", t1]
  db.exec "insert into results values ($1, $2, $3, $4)", ["crystal-#{driver}-#{pool_size}", now, "t2", t2]
  db.exec "insert into results values ($1, $2, $3, $4)", ["crystal-#{driver}-#{pool_size}", now, "t3", t3]
  db.exec "insert into results values ($1, $2, $3, $4)", ["crystal-#{driver}-#{pool_size}", now, "t4", t4]
  db.exec "insert into results values ($1, $2, $3, $4)", ["crystal-#{driver}-#{pool_size}", now, "t5", t5]
  db.exec "insert into results values ($1, $2, $3, $4)", ["crystal-#{driver}-#{pool_size}", now, "t6", t6]
  db.exec "insert into results values ($1, $2, $3, $4)", ["crystal-#{driver}-#{pool_size}", now, "t7", t7]
  db.exec "insert into results values ($1, $2, $3, $4)", ["crystal-#{driver}-#{pool_size}", now, "t8", t8]
end
