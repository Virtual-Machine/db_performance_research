# db_performance_research
Research on database performance for use in web application APIs.

I am in particular, investigating Crystal's database performance compared to other languages I typically would use to access database information.


I welcome pull requests that will:

Improve existing implementations (without sacrificing readability)

or

Add implementations for the following languages:
Python, Lua, Nim, Java, Kotlin, Swift, Javascript, Shell

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


### Official Implementation Comparisons

#### C
- Using github.com/postgres/postgres - libPQ

#### Golang
- Using github.com/lib/pq

#### Crystal
- Using github.com/will/crystal-pg
- Using github.com/abidon/crystal-pq
- Using github.com/abidon/libpq.cr

#### Ruby 
- Using github.com/ged/ruby-pg


Feedback is welcome in the issues. Feel free to leave comments or concerns.

### Caveats
- C implementation very likely could be improved further.
- Could possibly enable faster optimizations for C binary.
- Currently only tests synchronous, non-concurrent requests.
- Crystal's connection pool is currently configured to handle 1 max connection
- Go's connection pool is left to default configuration
- I want to extend these benchmarks with additional test cases and also test concurrent requests.

- NOTE : Benchmarks could be very unfair across implmentations currently, hoping to reduce this


### Structure

This research is strictly concerned with database performance and not web server performance.

Therefore the benchmarks will only measure the time it takes between submitting a query and receiving a valid response.

All implementations should be structured as follows to ensure comparisons remain as fair as possible:

1. binary/script should use connection pool if possible to manage connections to the database.
2. all benchmark queries should be read into string variables before any benchmarks begin
3. benchmark queries should be executed several times each to measure cumulative effects and reduce effect of outlier runs
4. binary/script should track all response times of each benchmark and print them on exit to std_out

### Database

For initial simplicity only PostgreSQL will be targeted but I may extend the results with MySQL at a future point.




