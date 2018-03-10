# echo "Building C binary"
# clang -xc O3 -o ../bin/c-pg ../languages/c/main.c 

echo "Building Crystal-PG"
crystal build --release --no-debug -Ddb_pg -o bin/crystal-pg languages/crystal/main.cr

echo "Building Crystal-PQ"
crystal build --release --no-debug -o bin/crystal-pq languages/crystal/main.cr

# echo "Building Go binary"
# go build -ldflags "-s -w" -o ../bin/golang-pg ../languages/go/pg.go

# echo "Moving Ruby script"
# cp ../languages/ruby/pg.rb ../bin/ruby-pg.rb