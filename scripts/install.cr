puts "Get go dependancy"
`go get -u github.com/lib/pq`

puts "Get crystal dependancies"
`crystal deps`

puts "Get ruby dependancy"
`gem install pg`
