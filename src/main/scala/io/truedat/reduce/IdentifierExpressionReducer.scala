package io.truedat.reduce

import io.truedat.ast._
import io.truedat.eval.Scope

trait IdentifierExpressionReducer extends Reducible {
  this: IdentifierExpression =>

  val builtins: Map[String, Expression] = Map(
    "BinaryEncoding.Base64" -> `BinaryEncoding.Base64`,
    "BinaryEncoding.Hex" -> `BinaryEncoding.Hex`,
    "BinaryOccurrence.Optional" -> `BinaryOccurrence.Optional`,
    "BinaryOccurrence.Repeating" -> `BinaryOccurrence.Repeating`,
    "BinaryOccurrence.Required" -> `BinaryOccurrence.Required`,
    "ByteOrder.BigEndian" -> `ByteOrder.BigEndian`,
    "ByteOrder.LittleEndian" -> `ByteOrder.LittleEndian`,
    "Compression.Deflate" -> `Compression.Deflate`,
    "Compression.GZip" -> `Compression.GZip`,
    "Day.Sunday" -> `Day.Sunday`,
    "Day.Monday" -> `Day.Monday`,
    "Day.Tuesday" -> `Day.Tuesday`,
    "Day.Wednesday" -> `Day.Wednesday`,
    "Day.Thursday" -> `Day.Thursday`,
    "Day.Friday" -> `Day.Friday`,
    "Day.Saturday" -> `Day.Saturday`,
    "GroupKind.Global" -> `GroupKind.Global`,
    "GroupKind.Local" -> `GroupKind.Local`,
    "Int64.Type" -> NumberType,
    "JoinAlgorithm.Dynamic" -> `JoinAlgorithm.Dynamic`,
    "JoinAlgorithm.LeftHash" -> `JoinAlgorithm.LeftHash`,
    "JoinAlgorithm.LeftIndex" -> `JoinAlgorithm.LeftIndex`,
    "JoinAlgorithm.PairwiseHash" -> `JoinAlgorithm.PairwiseHash`,
    "JoinAlgorithm.RightHash" -> `JoinAlgorithm.RightHash`,
    "JoinAlgorithm.RightIndex" -> `JoinAlgorithm.RightIndex`,
    "JoinAlgorithm.SortMerge" -> `JoinAlgorithm.SortMerge`,
    "JoinKind.FullOuter" -> `JoinKind.FullOuter`,
    "JoinKind.Inner" -> `JoinKind.Inner`,
    "JoinKind.LeftAnti" -> `JoinKind.LeftAnti`,
    "JoinKind.LeftOuter" -> `JoinKind.LeftOuter`,
    "JoinKind.RightAnti" -> `JoinKind.RightAnti`,
    "JoinKind.RightOuter" -> `JoinKind.RightOuter`,
    "JoinSide.Left" -> `JoinSide.Left`,
    "JoinSide.Right" -> `JoinSide.Right`,
    "MissingField.Error" -> `MissingField.Error`,
    "MissingField.Ignore" -> `MissingField.Ignore`,
    "MissingField.UseNull" -> `MissingField.UseNull`,
    "Occurrence.All" -> `Occurrence.All`,
    "Occurrence.First" -> `Occurrence.First`,
    "Occurrence.Last" -> `Occurrence.Last`,
    "Occurrence.Optional" -> `Occurrence.Optional`,
    "Occurrence.Repeating" -> `Occurrence.Repeating`,
    "Occurrence.Required" -> `Occurrence.Required`,
    "Order.Ascending" -> `Order.Ascending`,
    "Order.Descending" -> `Order.Descending`,
    "QuoteStyle.Csv" -> `QuoteStyle.None`,
    "QuoteStyle.None" -> `QuoteStyle.None`,
    "RelativePosition.FromEnd" -> `RelativePosition.FromEnd`,
    "RelativePosition.FromStart" -> `RelativePosition.FromStart`,
    "Replacer.ReplaceText" -> `Replacer.ReplaceText`,
    "Replacer.ReplaceValue" -> `Replacer.ReplaceValue`,
    "RoundingMode.AwayFromZero" -> `RoundingMode.AwayFromZero`,
    "RoundingMode.Down" -> `RoundingMode.Down`,
    "RoundingMode.ToEven" -> `RoundingMode.ToEven`,
    "RoundingMode.TowardZero" -> `RoundingMode.TowardZero`,
    "RoundingMode.Up" -> `RoundingMode.Up`,
    "TextEncoding.Ascii" -> `TextEncoding.Ascii`,
    "TextEncoding.BigEndianUnicode" -> `TextEncoding.BigEndianUnicode`,
    "TextEncoding.Unicode" -> `TextEncoding.Unicode`,
    "TextEncoding.Utf16" -> `TextEncoding.Utf16`,
    "TextEncoding.Utf8" -> `TextEncoding.Utf8`,
    "TextEncoding.Windows" -> `TextEncoding.Windows`,
    "TraceLevel.Critical" -> `TraceLevel.Critical`,
    "TraceLevel.Error" -> `TraceLevel.Error`,
    "TraceLevel.Information" -> `TraceLevel.Information`,
    "TraceLevel.Verbose" -> `TraceLevel.Verbose`,
    "TraceLevel.Warning" -> `TraceLevel.Warning`
  )

  override def isReducible: Scope => Boolean = scope => {
    builtins.contains(identifier.id) ||
      scope.closestBinding(identifier).exists(_.isReduced)
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

  override def nextReducible: Scope => Option[Expression] = scope =>
    if (builtins.contains(identifier.id)) Some(this)
    else if (scope.closestBinding(identifier).exists(_.isReduced)) Some(this)
    else None
}
