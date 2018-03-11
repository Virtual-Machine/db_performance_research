#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <libpq-fe.h>
#include <sys/time.h>

static void
exit_nicely(PGconn *conn)
{
    PQfinish(conn);
    exit(1);
}

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
static PGconn *conn;
static PGresult *res;

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

        printf("Command failed:\n");        
        PQclear(res);
        exit_nicely(conn);
    }    

    PQclear(res);
}

void test2() {
    res = PQexec(conn, query2);
    
    if (PQresultStatus(res) != PGRES_TUPLES_OK) {

        printf("Select failed:\n");        
        PQclear(res);
        exit_nicely(conn);
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
            fprintf(stderr, "Command failed: %s", PQerrorMessage(conn));
            PQclear(res);
            exit_nicely(conn);
        }
        PQclear(res);
    }
}

void test4() {
    res = PQexec(conn, query4);
    
    if (PQresultStatus(res) != PGRES_TUPLES_OK) {

        printf("Select failed:\n");        
        PQclear(res);
        exit_nicely(conn);
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

        if (PQresultStatus(res) != PGRES_TUPLES_OK)
        {
            fprintf(stderr, "SELECT failed: %s", PQerrorMessage(conn));
            PQclear(res);
            exit_nicely(conn);
        }

        int rows = PQntuples(res);
    
        for(int j=0; j<rows; j++) {
            char *name = PQgetvalue(res, j, 0);
            char *age = PQgetvalue(res, j, 1);
        }

        PQclear(res);
    }
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

    
    conn = PQconnectdb("dbname = test");

    if (PQstatus(conn) != CONNECTION_OK)
    {
        fprintf(stderr, "Connection to database failed: %s",
                PQerrorMessage(conn));
        exit_nicely(conn);
    }

    double t1 = benchmark(&test1);
    double t2 = benchmark(&test2);
    double t3 = benchmark(&test3);
    double t4 = benchmark(&test4);
    double t5 = benchmark(&test5);

    PQfinish(conn);

    printf("c,%f,%f,%f,%f,%f\n", t1, t2, t3, t4, t5);


    return 0;
}