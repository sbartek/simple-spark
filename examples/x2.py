from pyspark.sql import SparkSession
import pyspark.sql.functions as F

if __name__ == "__main__":

    spark = SparkSession\
        .builder\
        .getOrCreate()

    lst = [(0, ), (1, ), (2, ), (3, )]
    dataset = spark.createDataFrame(lst, ["x"])
    dataset.show()
    x = dataset.select(
        F.sum(F.pow(F.col("x"), F.lit(2))).alias("sumSquares")
    ).collect()
    print("Sum of squares is ", x[0]["sumSquares"])
    spark.stop()
