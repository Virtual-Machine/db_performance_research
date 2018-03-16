puts "Get go dependancy"
`go get -u github.com/lib/pq`
`go get -u github.com/jackc/pgx`

puts "Get crystal dependancies"
`crystal deps`

puts "Get ruby dependancy"
`gem install pg`
