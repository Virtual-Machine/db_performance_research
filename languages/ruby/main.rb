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
      puts j
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

puts "ruby,#{t1},#{t2},#{t3},#{t4},#{t5},#{t6}"

conn.close
