import org.apache.spark.sql.{SparkSession, Row}
import org.apache.spark.sql.types.{StructType, StructField, StringType, IntegerType}
import org.apache.spark.sql.functions.{col, sum, pow, lit}

object SimpleSpark {
  def main(args: Array[String]) {

    val spark = SparkSession.builder.appName("Hello Spark").getOrCreate()

    val userData = Seq(
      Row("user1", 1),
      Row("user2", 2),
      Row("user1", 3),
      Row("user3", 4)
    )

    val userSchema = List(
      StructField("userId", StringType, true),
      StructField("spend", IntegerType, true)
    )

    val dataset = spark.createDataFrame(
      spark.sparkContext.parallelize(userData),
      StructType(userSchema)
    )

    val x = dataset.select(
        sum(pow(col("spend"), lit(2))).alias("sumSquares")
    ).collect()

    println("*********************")
    println(s"Sum of squares is ${x(0)}")
    println("*********************")

    spark.stop()
  }
}
