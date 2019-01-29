package io.truedat.reduce

import io.truedat.ast._
import io.truedat.eval.Scope

trait IdentifierExpressionReducer extends Reducible {
  this: IdentifierExpression =>

  val builtins: Map[String, Expression] = Map(
    "Day.Sunday" -> NumberLiteral("Day.Sunday"),
    "Day.Monday" -> NumberLiteral("Day.Monday"),
    "Day.Tuesday" -> NumberLiteral("Day.Tuesday"),
    "Day.Wednesday" -> NumberLiteral("Day.Wednesday"),
    "Day.Thursday" -> NumberLiteral("Day.Thursday"),
    "Day.Friday" -> NumberLiteral("Day.Friday"),
    "Day.Saturday" -> NumberLiteral("Day.Saturday"),
    "GroupKind.Global" -> NumberLiteral("GroupKind.Global"),
    "GroupKind.Local" -> NumberLiteral("GroupKind.Local"),
    "Int64.Type" -> NumberType,
    "JoinAlgorithm.Dynamic" -> NumberLiteral("JoinAlgorithm.Dynamic"),
    "JoinAlgorithm.LeftHash" -> NumberLiteral("JoinAlgorithm.LeftHash"),
    "JoinAlgorithm.LeftIndex" -> NumberLiteral("JoinAlgorithm.LeftIndex"),
    "JoinAlgorithm.PairwiseHash" -> NumberLiteral("JoinAlgorithm.PairwiseHash"),
    "JoinAlgorithm.RightHash" -> NumberLiteral("JoinAlgorithm.RightHash"),
    "JoinAlgorithm.RightIndex" -> NumberLiteral("JoinAlgorithm.RightIndex"),
    "JoinAlgorithm.SortMerge" -> NumberLiteral("JoinAlgorithm.SortMerge"),
    "JoinKind.FullOuter" -> NumberLiteral("JoinKind.FullOuter"),
    "JoinKind.Inner" -> NumberLiteral("JoinKind.Inner"),
    "JoinKind.LeftAnti" -> NumberLiteral("JoinKind.LeftAnti"),
    "JoinKind.LeftOuter" -> NumberLiteral("JoinKind.LeftOuter"),
    "JoinKind.RightAnti" -> NumberLiteral("JoinKind.RightAnti"),
    "JoinKind.RightOuter" -> NumberLiteral("JoinKind.RightOuter"),
    "JoinSide.Left" -> NumberLiteral("JoinSide.Left"),
    "JoinSide.Right" -> NumberLiteral("JoinSide.Right"),
    "MissingField.Error" -> TextLiteral("MissingField.Error"),
    "MissingField.Ignore" -> NumberLiteral("MissingField.Ignore"),
    "MissingField.UseNull" -> NumberLiteral("MissingField.UseNull"),
    "Occurrence.All" -> NumberLiteral("Occurrence.All"),
    "Occurrence.First" -> NumberLiteral("Occurrence.First"),
    "Occurrence.Last" -> NumberLiteral("Occurrence.Last"),
    "Order.Ascending" -> NumberLiteral("Order.Ascending"),
    "Order.Descending" -> NumberLiteral("Order.Descending"),
    "QuoteStyle.Csv" -> TextLiteral("QuoteStyle.None"),
    "QuoteStyle.None" -> TextLiteral("QuoteStyle.None"),
    "RelativePosition.FromEnd" -> NumberLiteral("RelativePosition.FromEnd"),
    "RelativePosition.FromStart" -> NumberLiteral("RelativePosition.FromStart"),
    "RoundingMode.AwayFromZero" -> NumberLiteral("RoundingMode.AwayFromZero"),
    "RoundingMode.Down" -> NumberLiteral("RoundingMode.Down"),
    "RoundingMode.ToEven" -> NumberLiteral("RoundingMode.ToEven"),
    "RoundingMode.TowardZero" -> NumberLiteral("RoundingMode.TowardZero"),
    "RoundingMode.Up" -> NumberLiteral("RoundingMode.Up"),
    "TextEncoding.Ascii" -> NumberLiteral("TextEncoding.Ascii"),
    "TextEncoding.BigEndianUnicode" -> NumberLiteral("TextEncoding.BigEndianUnicode"),
    "TextEncoding.Unicode" -> NumberLiteral("TextEncoding.Unicode"),
    "TextEncoding.Utf16" -> NumberLiteral("TextEncoding.Utf16"),
    "TextEncoding.Utf8" -> NumberLiteral("TextEncoding.Utf8"),
    "TextEncoding.Windows" -> NumberLiteral("TextEncoding.Windows"),
    "TraceLevel.Critical" -> NumberLiteral("TraceLevel.Critical"),
    "TraceLevel.Error" -> NumberLiteral("TraceLevel.Error"),
    "TraceLevel.Information" -> NumberLiteral("TraceLevel.Information"),
    "TraceLevel.Verbose" -> NumberLiteral("TraceLevel.Verbose"),
    "TraceLevel.Warning" -> NumberLiteral("TraceLevel.Warning")
  )

  override def isReducible: Scope => Boolean = scope => {
    if (builtins.contains(identifier.id))
      true
    else {
      val binding = scope.closestBinding(identifier)
      binding.isDefined && binding.get.isReduced
    }
  }

  override def reduce: Scope => Expression = scope =>
    builtins.get(identifier.id) match {
      case Some(e) => e
      case None => scope.closestBinding(identifier) match {
        case Some(e) => e
        case None =>
          throw new IllegalArgumentException("Cannot reduce identifier " + identifier.id)
      }
    }

}
