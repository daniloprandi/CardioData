from pyspark.sql import SparkSession
from CardioPkg import cardio_funcs as cf, connections as c

try:
  spark = SparkSession.builder.getOrCreate()
  cardio_data_df = spark.read.csv(c.cardio_con, schema = cf.cardioSchema, header = 'true')
  cardio_data_df.select("*").show(5)
  #print(f'my csv is of type {type(cardio_data_df)}')
except:
  print('Problems ...')

spark.stop()