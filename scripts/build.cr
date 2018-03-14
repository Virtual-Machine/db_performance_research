require "crust"

puts "Building C binary"
`clang -optimize=3 -o bin/c-pg languages/c/main.c -lpq`

puts "Building Crystal-PG"
release_build("languages/crystal/main.cr", "bin/crystal-pg", "-Ddb_pg")

puts "Building Crystal-PQ"
release_build("languages/crystal/main.cr", "bin/crystal-pq")

puts "Building Crystal-LibPQ"
release_build("languages/crystal/libpq.cr", "bin/crystal-libpq")

puts "Building Go binary"
release_build("languages/go/pg.go", "bin/golang-pg")

puts "Moving Ruby script"
release_build("languages/ruby/main.rb", "bin/ruby-pg.rb")
