#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <libpq-fe.h>
#include <sys/time.h>
#include <pthread.h>

char * load_file(char *name){
    FILE *fp;
    char *buffer;
    fp = fopen ( name , "rb" );
    if( !fp ) perror(name),exit(1);

    fseek( fp , 0L , SEEK_END);
    int lSize = ftell( fp );
    rewind( fp );

    buffer = calloc( 1, lSize+1 );
    if( !buffer ) fclose(fp),fputs("memory alloc fails",stderr),exit(1);

    if( 1!=fread( buffer , lSize, 1 , fp) )
      fclose(fp),free(buffer),fputs("entire read fails",stderr),exit(1);

    fclose(fp);
    return buffer;
}

static char *query1;
static char *query2;
static char *query3;
static char *query4;
static char *query5;
static char *query6;
static PGconn *conn;
static PGresult *res;

static void
exit_nicely()
{
    printf("%s", PQerrorMessage(conn));
    PQfinish(conn);
    exit(1);
}


double benchmark(void (*functionPtr)()){
    struct timeval start, stop;
    double secs = 0;

    gettimeofday(&start, NULL);

    (*functionPtr)();

    gettimeofday(&stop, NULL);
    secs = (double)(stop.tv_usec - start.tv_usec) / 1000000 + (double)(stop.tv_sec - start.tv_sec);
    return secs;
}

void test1() {
    res = PQexec(conn, query1);
    
    if (PQresultStatus(res) != PGRES_COMMAND_OK) {
        PQclear(res);
        exit_nicely();
    }    

    PQclear(res);
}

void test2() {
    res = PQexec(conn, query2);
    
    if (PQresultStatus(res) != PGRES_TUPLES_OK) {
        PQclear(res);
        exit_nicely();
    }

    int rows = PQntuples(res);
    
    for(int i=0; i<rows; i++) {
        char *name = PQgetvalue(res, i, 0);
        char *age = PQgetvalue(res, i, 1);
    }
  

    PQclear(res);
}

void test3() {
    for(int i = 0; i < 1000; i++){
        char arg1[11] = {0};
        sprintf(arg1, "a test %d", i);
        char arg2[5] = {0};
        sprintf(arg2, "%d", i);
        const char *arguments[] = {arg1, arg2};
        res = PQexecParams(conn,query3,2,NULL,arguments,NULL,NULL,0);

        if (PQresultStatus(res) != PGRES_COMMAND_OK)
        {
            PQclear(res);
            exit_nicely();
        }
        PQclear(res);
    }
}

void test4() {
    res = PQexec(conn, query4);
    
    if (PQresultStatus(res) != PGRES_TUPLES_OK) {
        PQclear(res);
        exit_nicely();
    }

    int rows = PQntuples(res);
    
    for(int i=0; i<rows; i++) {
        char *name = PQgetvalue(res, i, 0);
        char *age = PQgetvalue(res, i, 1);
    }
  

    PQclear(res);
}

void test5() {
    for(int i = 0; i < 1000; i++){
        char arg1[10] = {0};
        sprintf(arg1, "%d", i);
        const char *arguments[] = {arg1};
        res = PQexecParams(conn,query5,1,NULL,arguments,NULL,NULL,0);

        if (PQresultStatus(res) != PGRES_TUPLES_OK) {
            PQclear(res);
            exit_nicely();
        }

        int rows = PQntuples(res);
    
        for(int j=0; j<rows; j++) {
            char *name = PQgetvalue(res, j, 0);
            char *age = PQgetvalue(res, j, 1);
        }

        PQclear(res);
    }
}

void *myThreadFun(void *vargp)
{
    PGconn *temp_conn = PQconnectdb("dbname = test");
    if (PQstatus(temp_conn) != CONNECTION_OK)
    {
        fprintf(stderr, "Connection to database failed: %s",
                PQerrorMessage(temp_conn));
        exit_nicely();
    }
    int *myid = (int *)vargp;
    char arg1[10] = {0};
    sprintf(arg1, "%d", *myid);
    const char *arguments[] = {arg1};
    PGresult *temp_res = PQexecParams(temp_conn,"select name, age from contacts where age = $1",1,NULL,arguments,NULL,NULL,0);

    if (PQresultStatus(temp_res) != PGRES_TUPLES_OK) {
        PQclear(temp_res);
        exit_nicely();
    }

    int rows = PQntuples(temp_res);


    for(int j=0; j<rows; j++) {
        char *name = PQgetvalue(temp_res, j, 0);
        char *age = PQgetvalue(temp_res, j, 1);
    }

    PQclear(temp_res);
    PQfinish(temp_conn);
    return NULL;
}

void test6() {
  pthread_t thr[100];
  int i, rc;
 
  /* create threads */
  for (i = 0; i < 100; ++i) {
    int *temp_int = malloc(sizeof i);
    *temp_int = i;

    if ((rc = pthread_create(&thr[i], NULL, myThreadFun, temp_int))) {
      fprintf(stderr, "error: pthread_create, rc: %d\n", rc);
    }
  }
  /* block until all threads complete */
  for (i = 0; i < 100; ++i) {
    pthread_join(thr[i], NULL);
  }
}

void test7() {
    res = PQexec(conn, query6);
    
    if (PQresultStatus(res) != PGRES_TUPLES_OK) {
        PQclear(res);
        exit_nicely();
    }

    int rows = PQntuples(res);
    
    for(int i=0; i<rows; i++) {
        char *id = PQgetvalue(res, i, 0);
        char *f_id = PQgetvalue(res, i, 1);
        char *f_bool = PQgetvalue(res, i, 2);
        char *f_string = PQgetvalue(res, i, 3);
        char *f_decimal = PQgetvalue(res, i, 4);
        char *f_date = PQgetvalue(res, i, 5);
        char *f_time = PQgetvalue(res, i, 6);
    }
  

    PQclear(res);
}

void log_result(struct tm* info, char *name, double res){
    char arg1[2] = {0};
    sprintf(arg1, "%s", "c");
    char arg2[80] = {0};
    strftime(arg2, sizeof(arg2), "%Y-%m-%d %H:%M:%S", info);
    char arg4[19] = {0};
    sprintf(arg4, "%f", res);
    const char *arguments[] = {arg1, arg2, name, arg4};
    PQexecParams(conn,"insert into results values ($1, $2, $3, $4)",4,NULL,arguments,NULL,NULL,0);
}

int
main(int argc, char **argv)
{
    long lSize;

    query1 = load_file("sql/query1.sql");
    query2 = load_file("sql/query2.sql");
    query3 = load_file("sql/query3.sql");
    query4 = load_file("sql/query4.sql");
    query5 = load_file("sql/query5.sql");
    query6 = load_file("sql/query6.sql");

    
    conn = PQconnectdb("dbname = test");

    if (PQstatus(conn) != CONNECTION_OK)
    {
        fprintf(stderr, "Connection to database failed: %s",
                PQerrorMessage(conn));
        exit_nicely();
    }

    double t1 = benchmark(&test1);
    double t2 = benchmark(&test2);
    double t3 = benchmark(&test3);
    double t4 = benchmark(&test4);
    double t5 = benchmark(&test5);
    double t6 = benchmark(&test6);
    double t7 = benchmark(&test7);

    time_t now;
    time(&now);
    struct tm *info;
    info = localtime( &now );

    log_result(info, "t1", t1);
    log_result(info, "t2", t2);
    log_result(info, "t3", t3);
    log_result(info, "t4", t4);
    log_result(info, "t5", t5);
    log_result(info, "t6", t6);
    log_result(info, "t7", t7);

    PQfinish(conn);

    return 0;
}