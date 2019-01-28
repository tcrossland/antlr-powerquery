package io.truedat.functions

import io.truedat.ast._

object DataAccessFunctions {

  def dataSource: (String, List[Expression]) => Expression = {
    case (sourceType, args) =>
      DataSource(
        sourceType,
        args.map(_.asInstanceOf[Value])
      )
    case _ =>
      throw new IllegalArgumentException("Expected 1-4 arguments")
  }
}
