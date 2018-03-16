# db_performance_research
PostgreSQL Database Driver Benchmarks

I welcome pull requests that will:

`Improve existing implementations (without sacrificing readability)`

or

`Add implementations for the following languages:
Python, Lua, Nim, Java, Kotlin, Swift, Javascript, Shell`

### Getting Started

You will need the following on your system to be able to run the tests:

1. postgresql
2. clang
3. go
4. crystal
5. ruby
6. libpq in system include path
7. run the install script
```
crystal run scripts/install.cr
```
8. now you can build, run, and summarize the results
```
crystal run scripts/build.cr
crystal run scripts/run.cr
crystal run scripts/summary.cr
```


### Driver Comparisons

#### C
- Using github.com/postgres/postgres - libPQ

#### Golang
- Using github.com/lib/pq
- Using github.com/jackc/pgx via native interface and connection pool

#### Crystal
- Using github.com/will/crystal-pg
- Using github.com/abidon/crystal-pq
- Using github.com/abidon/libpq.cr

#### Ruby 
- Using github.com/ged/ruby-pg


Feedback is welcome in the issues. Feel free to leave comments or concerns.

### Caveats
- NOTE : Benchmarks could be unfair across implementations currently, hoping to reduce this
- C, and Ruby are currently not being tested concurrently.


### Structure

This research is strictly concerned with database performance and not web server performance.

Therefore the benchmarks will only measure the time it takes between submitting a query and receiving a valid response.

All implementations should be structured as follows to ensure comparisons remain as fair as possible:

1. binary/script should use connection pool if possible to manage connections to the database.
2. all benchmark queries should be read into string variables before any benchmarks begin
3. benchmark queries should be executed several times each to measure cumulative effects and reduce effect of outlier runs
4. binary/script should track all response times of each benchmark and print them on exit to std_out


### Tests

#### Simple Tests
1. T1 - delete from contacts where name like 'a test %' (1000 record delete with wildcard search)
2. T2 - select name, age from contacts order by age desc (1 select retrieving 1000 records into local variables)
3. T3 - insert into contacts values ($1, $2) (1000 individual inserts using execution parameters)
4. T4 - select name, age from contacts order by age asc (1 select retrieving 2000 records into local variables)
5. T5 - select name, age from contacts where age = $1 (1000 individual selects using execution parameters)
6. T6 - select name, age from contacts where age = $1 (1000 concurrent selects using execution parameters)






