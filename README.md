# db_performance_research
Research on database performance for use in web application APIs.

I am in particular, investigating Crystal's database performance compared to other languages I typically would use to access database information.


I welcome pull requests that will:

Improve existing implementations (without sacrificing readability)

or

Add implementations for the following languages:
Python, Lua, Nim, Java, Kotlin, Swift, Javascript, Shell


### Official Target Comparisons

#### C
- Suspected to be the fastest, chosen to represent the high water mark.

#### Golang
- Fellow compiled language, chosen to represent a language expected to perform similar to Crystal.

#### Crystal
- Main focus of this research.

#### Ruby
- Interpreted language that is similar in syntax to Crystal, and the minimum standard of performance needed to meet expectations.


Feedback is welcome in the issues. Feel free to leave comments or concerns.


### Structure

This research is strictly concerned with database performance and not web server performance.

Therefore the benchmarks will only measure the time it takes between submitting a query and receiving a valid response.

All implementations should be structured as follows to ensure comparisons remain as fair as possible:

1. binary/script should accept connection string for the database as a single command line argument.
2. binary/script should use connection pool if possible to manage connections to the database
3. all benchmark queries should be read into string variables before any benchmarks begin
4. benchmark queries should be executed several times each to measure cumulative effects and reduce effect of outlier runs
5. binary/script should track all response times of each benchmark and print them on exit to std_out

### Database

For initial simplicity only PostgreSQL will be targeted but I may extend the results with MySQL at a future point.




