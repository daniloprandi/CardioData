from pyspark.sql.types import StructType

cardioSchema = StructType() \
  .add('id', 'integer')\
  .add('age', 'integer')\
  .add('gender', 'integer')\
  .add('height', 'float')\
  .add('weight', 'float')\
  .add('ap_hi', 'integer')\
  .add('ap_lo', 'integer')\
  .add('cholesterol', 'integer')\
  .add('gluc', 'integer')\
  .add('smoke', 'integer')\
  .add('alco', 'integer')\
  .add('active', 'integer')\
  .add('cardio', 'integer')\
  .add('age_years', 'integer')\
  .add('bmi', 'float')\
  .add('bp_category', 'string')\
  .add('bp_category_encoded', 'string')