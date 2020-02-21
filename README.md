# Synthetic procedures based on TPC-DS queries
To show the scalability and efficiency of procedure optimization, we generated synthetic procedures by extending the queries in the TPC-DS benchmark.

We chose 34 CTE queries represented by multiple statements among the TPC-DS benchmark queries since the procedure is designed by multiple statements. Because 24 out of 34 queries have less than 0.3 seconds of execution time, we only used the remaining 10 CTE queries (their ids : 4, 11, 23\_1, 23\_2, 51, 59, 74, 75, 78, and 97) from TPC-DS benchmark. 

For each CTE query, we make the procedure which are defined as multiple table variables corresponding CTE variables.
Then, we move some filters among multiple queries with keeping query semantic. Finally, we insert if and loop into the suitable points in the procedure. Last two steps are essential to show superiority of our algorithm.
Therefore, we denote We denote these 30 procedures as func1, func2,..., func10 and each case has sequential,branch, loop logics.

The detail explanation is described as top in each file.


