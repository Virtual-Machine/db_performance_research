require "crust"

puts "Building C binary"
`clang -optimize=3 -o bin/c-pg languages/c/main.c -lpq`

puts "Building Crystal-PG"
release_build("-Ddb_pg languages/crystal/main.cr", "bin/crystal-pg")

puts "Building Crystal-PQ"
release_build("languages/crystal/main.cr", "bin/crystal-pq")

puts "Building Go binary"
`go build -ldflags "-s -w" -o bin/golang-pg languages/go/pg.go`

puts "Moving Ruby script"
`cp languages/ruby/main.rb bin/ruby-pg.rb`
