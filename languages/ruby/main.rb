#!/usr/bin/env ruby

require 'pg'

conn = PG.connect( dbname: 'test' )

def benchmark(&block)
  t1 = Time.now
  yield
  t2 = Time.now
  t2 - t1
end

results = []

query1 = File.read "sql/query1.sql"
query2 = File.read "sql/query2.sql"
query3 = File.read "sql/query3.sql"
query4 = File.read "sql/query4.sql"
query5 = File.read "sql/query5.sql"
query6 = File.read "sql/query6.sql"
query7 = File.read "sql/query7.sql"


t1 = benchmark do
  conn.exec( query1 )
end

t2 = benchmark do
  conn.exec( query2 ) do |result|
    result.each do |row|
      name, age = row.values_at('name', 'age')
    end
  end
end

t3 = benchmark do
  1000.times do |i|
    conn.exec( query3, ["a test #{i}", i] )
  end
end

t4 = benchmark do
  conn.exec( query4 ) do |result|
    result.each do |row|
      name, age = row.values_at('name', 'age')
    end
  end
end

t5 = benchmark do
  1000.times do |i|
    conn.exec( query5, [i] ) do |result|
      result.each do |row|
        name, age = row.values_at('name', 'age')
      end
    end
  end
end

t6 = benchmark do
  threads = []
  100.times do |i|
    threads << Thread.new(i) do |j|
      conn_concurrent = PG.connect( dbname: 'test' )
      conn_concurrent.exec( query5, [j] ) do |result|
        result.each do |row|
          name, age = row.values_at('name', 'age')
        end
        conn_concurrent.close
      end
    end
  end
  threads.each do |thread|
    thread.join
  end
end

t7 = benchmark do
  conn.exec( query6 ) do |result|
    result.each do |row|
      id, f_id, f_bool, f_string, f_decimal, f_date, f_time = row.values_at('id', 'f_id', 'f_bool', 'f_string', 'f_decimal', 'f_date', 'f_time')
    end
  end
end

t8 = benchmark do
  conn.exec( query7 ) do |result|
    sum = 0
    result.each do |row|
      f_id = row.values_at('f_id')
      sum += f_id[0].to_i
    end
    if sum != 2249638468
      throw Error.new "Invalid sum, something went wrong"
    end
  end
end

now = Time.now
conn.exec( "insert into results values ($1, $2, $3, $4)", ["ruby", now, "t1", t1] )
conn.exec( "insert into results values ($1, $2, $3, $4)", ["ruby", now, "t2", t2] )
conn.exec( "insert into results values ($1, $2, $3, $4)", ["ruby", now, "t3", t3] )
conn.exec( "insert into results values ($1, $2, $3, $4)", ["ruby", now, "t4", t4] )
conn.exec( "insert into results values ($1, $2, $3, $4)", ["ruby", now, "t5", t5] )
conn.exec( "insert into results values ($1, $2, $3, $4)", ["ruby", now, "t6", t6] )
conn.exec( "insert into results values ($1, $2, $3, $4)", ["ruby", now, "t7", t7] )
conn.exec( "insert into results values ($1, $2, $3, $4)", ["ruby", now, "t8", t8] )

conn.close
