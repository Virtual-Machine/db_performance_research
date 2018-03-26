# Caveats

There are a number of differences across the language implementations. This clarifies the known discrepancies.

### C
- Uses a single connection
- Only queries into string buffers
- Uses pthreads to acheive concurrency

### Ruby
- Uses a single connection
- Queries into default duck typed variables from query

### Go
- Uses golang default connection pool settings
- Currently having an issue with database/sql when using goroutines in pg.go (T6)

### Crystal
- Libpq uses a single connection
- Crystal-PG and Crystal-PQ use connection pool with command line provided # of connections
- Crystal-PQ is not detecting time in a result set currently. (T7)