require "libpq"

def benchmark(&block) : String
  t1 = Time.now
  yield
  t2 = Time.now
  diff = t2 - t1
  sprintf("%.6f", diff.total_seconds)
end

conn = LibPQ.connect_db("postgres://dwork@localhost:5432/test")

query1 = File.read "sql/query1.sql"
query2 = File.read "sql/query2.sql"
query3 = File.read "sql/query3.sql"
query4 = File.read "sql/query4.sql"
query5 = File.read "sql/query5.sql"
query6 = File.read "sql/query6.sql"
query7 = File.read "sql/query7.sql"

t1 = benchmark do
  LibPQ.exec conn, query1
end

t2 = benchmark do
  res = LibPQ.exec conn, query2
  rows = LibPQ.ntuples res
  rows.times do |i|
    name = String.new(LibPQ.get_value res, i, 0)
    age = String.new(LibPQ.get_value res, i, 1)
  end
end

t3 = benchmark do
  1000.times do |i|
    args = ["a test #{i}".to_unsafe, "#{i}".to_unsafe].to_unsafe
    LibPQ.exec_params conn, query3, 2, nil, args, nil, nil, 0
  end
end

t4 = benchmark do
  res = LibPQ.exec conn, query4
  rows = LibPQ.ntuples res
  rows.times do |i|
    name = String.new(LibPQ.get_value res, i, 0)
    age = String.new(LibPQ.get_value res, i, 1)
  end
end

t5 = benchmark do
  1000.times do |i|
    args = ["#{i}".to_unsafe].to_unsafe
    res = LibPQ.exec_params conn, query5, 1, nil, args, nil, nil, 0
    rows = LibPQ.ntuples res
    rows.times do |i|
      name = String.new(LibPQ.get_value res, i, 0)
      age = String.new(LibPQ.get_value res, i, 1)
    end
  end
end

t6 = benchmark do
  channel = Channel(Nil).new(100)
  100.times do |i|
    proc = ->(j : Int32) do
      spawn do
        temp_conn = LibPQ.connect_db("postgres://dwork@localhost:5432/test")
        args = ["#{j}".to_unsafe].to_unsafe
        res = LibPQ.exec_params temp_conn, query5, 1, nil, args, nil, nil, 0
        rows = LibPQ.ntuples res
        rows.times do |x|
          name = String.new(LibPQ.get_value res, x, 0)
          age = String.new(LibPQ.get_value res, x, 1)
        end
        LibPQ.finish(temp_conn)
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
  res = LibPQ.exec conn, query6
  rows = LibPQ.ntuples res
  rows.times do |i|
    id = String.new(LibPQ.get_value res, i, 0)
    f_id = String.new(LibPQ.get_value res, i, 1)
    f_bool = String.new(LibPQ.get_value res, i, 2)
    f_string = String.new(LibPQ.get_value res, i, 3)
    f_decimal = String.new(LibPQ.get_value res, i, 4)
    f_date = String.new(LibPQ.get_value res, i, 5)
    f_time = String.new(LibPQ.get_value res, i, 6)
  end
end

t8 = benchmark do
  res = LibPQ.exec conn, query7
  rows = LibPQ.ntuples res
  sum = 0.to_i64
  rows.times do |i|
    f_id = String.new(LibPQ.get_value res, i, 0)
    sum += f_id.to_i
  end
  if sum != 2249638468
    raise Exception.new "Invalid sum, something went wrong"
  end
end

now = Time.now
args = ["crystal-libpq".to_unsafe, now.to_s.to_unsafe, "t1".to_unsafe, t1.to_unsafe].to_unsafe
LibPQ.exec_params conn, "insert into results values ($1, $2, $3, $4)", 4, nil, args, nil, nil, 0
args = ["crystal-libpq".to_unsafe, now.to_s.to_unsafe, "t2".to_unsafe, t2.to_unsafe].to_unsafe
LibPQ.exec_params conn, "insert into results values ($1, $2, $3, $4)", 4, nil, args, nil, nil, 0
args = ["crystal-libpq".to_unsafe, now.to_s.to_unsafe, "t3".to_unsafe, t3.to_unsafe].to_unsafe
LibPQ.exec_params conn, "insert into results values ($1, $2, $3, $4)", 4, nil, args, nil, nil, 0
args = ["crystal-libpq".to_unsafe, now.to_s.to_unsafe, "t4".to_unsafe, t4.to_unsafe].to_unsafe
LibPQ.exec_params conn, "insert into results values ($1, $2, $3, $4)", 4, nil, args, nil, nil, 0
args = ["crystal-libpq".to_unsafe, now.to_s.to_unsafe, "t5".to_unsafe, t5.to_unsafe].to_unsafe
LibPQ.exec_params conn, "insert into results values ($1, $2, $3, $4)", 4, nil, args, nil, nil, 0
args = ["crystal-libpq".to_unsafe, now.to_s.to_unsafe, "t6".to_unsafe, t6.to_unsafe].to_unsafe
LibPQ.exec_params conn, "insert into results values ($1, $2, $3, $4)", 4, nil, args, nil, nil, 0
args = ["crystal-libpq".to_unsafe, now.to_s.to_unsafe, "t7".to_unsafe, t7.to_unsafe].to_unsafe
LibPQ.exec_params conn, "insert into results values ($1, $2, $3, $4)", 4, nil, args, nil, nil, 0
args = ["crystal-libpq".to_unsafe, now.to_s.to_unsafe, "t8".to_unsafe, t8.to_unsafe].to_unsafe
LibPQ.exec_params conn, "insert into results values ($1, $2, $3, $4)", 4, nil, args, nil, nil, 0

LibPQ.finish conn
