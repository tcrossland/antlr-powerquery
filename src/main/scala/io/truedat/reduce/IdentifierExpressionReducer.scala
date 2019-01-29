package io.truedat.reduce

import io.truedat.ast._
import io.truedat.eval.Scope

trait IdentifierExpressionReducer extends Reducible {
  this: IdentifierExpression =>

  val builtins: Map[String, Expression] = Map(
    "BinaryEncoding.Base64" -> Builtin("BinaryEncoding.Base64"),
    "BinaryEncoding.Hex" -> Builtin("BinaryEncoding.Hex"),
    "BinaryOccurrence.Optional" -> Builtin("BinaryOccurrence.Optional"),
    "BinaryOccurrence.Repeating" -> Builtin("BinaryOccurrence.Repeating"),
    "BinaryOccurrence.Required" -> Builtin("BinaryOccurrence.Required"),
    "ByteOrder.BigEndian" -> Builtin("ByteOrder.BigEndian"),
    "ByteOrder.LittleEndian" -> Builtin("ByteOrder.LittleEndian"),
    "Compression.Deflate" -> Builtin("Compression.Deflate"),
    "Compression.GZip" -> Builtin("Compression.GZip"),
    "Day.Sunday" -> Builtin("Day.Sunday"),
    "Day.Monday" -> Builtin("Day.Monday"),
    "Day.Tuesday" -> Builtin("Day.Tuesday"),
    "Day.Wednesday" -> Builtin("Day.Wednesday"),
    "Day.Thursday" -> Builtin("Day.Thursday"),
    "Day.Friday" -> Builtin("Day.Friday"),
    "Day.Saturday" -> Builtin("Day.Saturday"),
    "GroupKind.Global" -> Builtin("GroupKind.Global"),
    "GroupKind.Local" -> Builtin("GroupKind.Local"),
    "Int64.Type" -> NumberType,
    "JoinAlgorithm.Dynamic" -> Builtin("JoinAlgorithm.Dynamic"),
    "JoinAlgorithm.LeftHash" -> Builtin("JoinAlgorithm.LeftHash"),
    "JoinAlgorithm.LeftIndex" -> Builtin("JoinAlgorithm.LeftIndex"),
    "JoinAlgorithm.PairwiseHash" -> Builtin("JoinAlgorithm.PairwiseHash"),
    "JoinAlgorithm.RightHash" -> Builtin("JoinAlgorithm.RightHash"),
    "JoinAlgorithm.RightIndex" -> Builtin("JoinAlgorithm.RightIndex"),
    "JoinAlgorithm.SortMerge" -> Builtin("JoinAlgorithm.SortMerge"),
    "JoinKind.FullOuter" -> Builtin("JoinKind.FullOuter"),
    "JoinKind.Inner" -> Builtin("JoinKind.Inner"),
    "JoinKind.LeftAnti" -> Builtin("JoinKind.LeftAnti"),
    "JoinKind.LeftOuter" -> Builtin("JoinKind.LeftOuter"),
    "JoinKind.RightAnti" -> Builtin("JoinKind.RightAnti"),
    "JoinKind.RightOuter" -> Builtin("JoinKind.RightOuter"),
    "JoinSide.Left" -> Builtin("JoinSide.Left"),
    "JoinSide.Right" -> Builtin("JoinSide.Right"),
    "MissingField.Error" -> Builtin("MissingField.Error"),
    "MissingField.Ignore" -> Builtin("MissingField.Ignore"),
    "MissingField.UseNull" -> Builtin("MissingField.UseNull"),
    "Occurrence.All" -> Builtin("Occurrence.All"),
    "Occurrence.First" -> Builtin("Occurrence.First"),
    "Occurrence.Last" -> Builtin("Occurrence.Last"),
    "Occurrence.Optional" -> Builtin("Occurrence.Optional"),
    "Occurrence.Repeating" -> Builtin("Occurrence.Repeating"),
    "Occurrence.Required" -> Builtin("Occurrence.Required"),
    "Order.Ascending" -> Builtin("Order.Ascending"),
    "Order.Descending" -> Builtin("Order.Descending"),
    "QuoteStyle.Csv" -> Builtin("QuoteStyle.None"),
    "QuoteStyle.None" -> Builtin("QuoteStyle.None"),
    "RelativePosition.FromEnd" -> Builtin("RelativePosition.FromEnd"),
    "RelativePosition.FromStart" -> Builtin("RelativePosition.FromStart"),
    "Replacer.ReplaceText" -> Builtin("Replacer.ReplaceText"),
    "Replacer.ReplaceValue" -> Builtin("Replacer.ReplaceValue"),
    "RoundingMode.AwayFromZero" -> Builtin("RoundingMode.AwayFromZero"),
    "RoundingMode.Down" -> Builtin("RoundingMode.Down"),
    "RoundingMode.ToEven" -> Builtin("RoundingMode.ToEven"),
    "RoundingMode.TowardZero" -> Builtin("RoundingMode.TowardZero"),
    "RoundingMode.Up" -> Builtin("RoundingMode.Up"),
    "TextEncoding.Ascii" -> Builtin("TextEncoding.Ascii"),
    "TextEncoding.BigEndianUnicode" -> Builtin("TextEncoding.BigEndianUnicode"),
    "TextEncoding.Unicode" -> Builtin("TextEncoding.Unicode"),
    "TextEncoding.Utf16" -> Builtin("TextEncoding.Utf16"),
    "TextEncoding.Utf8" -> Builtin("TextEncoding.Utf8"),
    "TextEncoding.Windows" -> Builtin("TextEncoding.Windows"),
    "TraceLevel.Critical" -> Builtin("TraceLevel.Critical"),
    "TraceLevel.Error" -> Builtin("TraceLevel.Error"),
    "TraceLevel.Information" -> Builtin("TraceLevel.Information"),
    "TraceLevel.Verbose" -> Builtin("TraceLevel.Verbose"),
    "TraceLevel.Warning" -> Builtin("TraceLevel.Warning")
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
