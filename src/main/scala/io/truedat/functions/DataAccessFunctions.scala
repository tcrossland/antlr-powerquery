package io.truedat.functions

import io.truedat.ast._

object DataAccessFunctions extends Functions {

  val functions: Map[String, List[Expression] => Expression] = List(
    "Csv.Document",
    "DataLake.Contents",
    "Json.Document",
    "Sql.Database"
  ).map(s => (s, dataSource(s))).toMap

  def dataSource: String => List[Expression] => Expression = source => args =>
      DataSource(source, args)
}
