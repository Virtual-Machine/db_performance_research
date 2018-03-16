package main

import (
	"database/sql"
	"fmt"
	"io/ioutil"
	"time"

	_ "github.com/lib/pq"
)

func main() {
	connStr := "postgres://@localhost/test?sslmode=disable"

	q1, err := ioutil.ReadFile("sql/query1.sql")
	if err != nil {
		panic(err)
	}
	q2, err := ioutil.ReadFile("sql/query2.sql")
	if err != nil {
		panic(err)
	}
	q3, err := ioutil.ReadFile("sql/query3.sql")
	if err != nil {
		panic(err)
	}
	q4, err := ioutil.ReadFile("sql/query4.sql")
	if err != nil {
		panic(err)
	}
	q5, err := ioutil.ReadFile("sql/query5.sql")
	if err != nil {
		panic(err)
	}

	query1 := string(q1)
	query2 := string(q2)
	query3 := string(q3)
	query4 := string(q4)
	query5 := string(q5)

	db, err := sql.Open("postgres", connStr)
	if err != nil {
		panic(err.Error())
	}
	defer db.Close()

	err = db.Ping()
	if err != nil {
		panic(err.Error())
	}

	t1 := benchmark(func() {
		db.Exec(query1)
	})

	t2 := benchmark(func() {
		rows, err := db.Query(query2)
		if err != nil {
			panic(err)
		}
		defer rows.Close()
		var name string
		var age int
		for rows.Next() {
			err := rows.Scan(&name, &age)
			if err != nil {
				panic(err)
			}
		}
		err = rows.Err()
		if err != nil {
			panic(err)
		}
	})

	t3 := benchmark(func() {
		for i := 0; i < 1000; i++ {
			db.Exec(query3, fmt.Sprintf("a test %d", i), i)
		}
	})

	t4 := benchmark(func() {
		rows, err := db.Query(query4)
		if err != nil {
			panic(err)
		}
		defer rows.Close()
		var name string
		var age int
		for rows.Next() {
			err := rows.Scan(&name, &age)
			if err != nil {
				panic(err)
			}
		}
		err = rows.Err()
		if err != nil {
			panic(err)
		}
	})

	t5 := benchmark(func() {
		for i := 0; i < 1000; i++ {
			rows, err := db.Query(query5, i)
			if err != nil {
				panic(err)
			}
			defer rows.Close()
			var name string
			var age int
			for rows.Next() {
				err := rows.Scan(&name, &age)
				if err != nil {
					panic(err)
				}
			}
			err = rows.Err()
			if err != nil {
				panic(err)
			}
		}
	})

	t6 := benchmark(func() {
		channel := make(chan int, 100)
		for i := 0; i < 100; i++ {
			go func(j int) {
				rows, err := db.Query(query5, j)
				if err != nil {
					panic(err)
				}
				var name string
				var age int
				for rows.Next() {
					err := rows.Scan(&name, &age)
					if err != nil {
						panic(err)
					}
				}
				err = rows.Err()
				if err != nil {
					panic(err)
				}
				rows.Close()
				channel <- 0
			}(i)
		}

		for i := 0; i < 100; i++ {
			<-channel
		}
	})

	fmt.Printf("go-pg,%f,%f,%f,%f,%f,%f\n", t1, t2, t3, t4, t5, t6)
}

func benchmark(test func()) float64 {
	t1 := time.Now()
	test()
	t2 := time.Now()
	return t2.Sub(t1).Seconds()
}
