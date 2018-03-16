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
    proc = ->(x : Int32) do
      spawn do
        args = ["#{i}".to_unsafe].to_unsafe
        res = LibPQ.exec_params conn, query5, 1, nil, args, nil, nil, 0
        rows = LibPQ.ntuples res
        rows.times do |i|
          name = String.new(LibPQ.get_value res, i, 0)
          age = String.new(LibPQ.get_value res, i, 1)
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

puts "crystal-libpq,#{t1},#{t2},#{t3},#{t4},#{t5},#{t6}"

LibPQ.finish conn
