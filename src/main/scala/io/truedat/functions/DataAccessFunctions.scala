package io.truedat.functions

import io.truedat.ast._

object DataAccessFunctions {

  val functions: Map[String, List[Expression] => Expression] = Map(
    "Csv.Document" -> `Csv.Document`.apply,
    "DataLake.Contents" -> `DataLake.Contents`.apply,
    "Json.Document" -> `Json.Document`.apply,
    "Sql.Database" -> `Sql.Database`.apply
  )
}

abstract class DataAccessFunction extends LibraryFunction {
  override def toString: String = args.mkString(functionName + "(", "," , ")")
}
case class `Csv.Document`(args: List[Expression]) extends DataAccessFunction
case class `DataLake.Contents`(args: List[Expression]) extends DataAccessFunction
case class `Json.Document`(args: List[Expression]) extends DataAccessFunction
case class `Sql.Database`(args: List[Expression]) extends DataAccessFunction
