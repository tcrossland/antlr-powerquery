package io.truedat.extract

import com.typesafe.scalalogging.Logger
import io.truedat.ast._
import io.truedat.functions._

object DictionaryContext {
  val logger: Logger = Logger[DictionaryContext.type]

  def extractFields: Expression => Set[String] = {
    case `#table`(NumberLiteral(columns) :: _) =>
      val fields = (1 to columns.toInt).map("Column" + _).toSet
      logger.trace("#table -> " + fields.toString)
      fields
    case `Table.AddColumn`(table :: TextLiteral(newColumnName) :: _) =>
      val existingFields = extractFields(table)
      val fields = existingFields + newColumnName
      logger.trace("Table.AddColumn -> " + fields.toString)
      fields
    case `Table.ColumnNames`(table :: _) =>
      val fields = extractFields(table)
      logger.trace("Table.ColumnNames -> " + fields.toString)
      fields
    case `Table.Combine`(ItemList(tables) :: Nil) =>
      val fields = tables.map(extractFields).reduce(_ ++ _)
      logger.trace("Table.Combine -> " + fields.toString)
      fields
    case `Table.DuplicateColumn`(table :: TextLiteral(columnName) :: TextLiteral(newColumnName) :: _) =>
      val fields = extractFields(table) + columnName + newColumnName
      logger.trace("Table.DuplicateColumn -> " + fields.toString)
      fields
    case `Table.ExpandTableColumn`(table :: TextLiteral(column) :: _ :: ListLiteral(newColumnNames) :: _) =>
      val existingFields = extractFields(table)
      val fieldsToAdd = newColumnNames.map(_.toString)
      val fields = existingFields - column ++ fieldsToAdd
      logger.trace("Table.ExpandTableColumn -> " + fields.toString)
      fields
    case `Table.ExpandTableColumn`(table :: TextLiteral(column) :: ListLiteral(columnNames) :: _) =>
      val existingFields = extractFields(table)
      val fieldsToAdd = columnNames.map(Arguments.itemToString)
      val fields = existingFields - column ++ fieldsToAdd
      logger.trace("Table.ExpandTableColumn -> " + fields.toString)
      fields
    case `Table.ExpandTableColumn`(table :: TextLiteral(column) :: (columnNames: Expression) :: _) =>
      val existingFields = extractFields(table)
      val fieldsToAdd = extractFields(columnNames)
      val fields = existingFields - column ++ fieldsToAdd
      logger.trace("Table.ExpandTableColumn -> " + fields.toString)
      fields
    case `Table.FromRecords`(ListLiteral(records) :: Nil) =>
      val fields = records
        .map(_.asInstanceOf[RecordLiteral])
        .map(Arguments.recordLiteralToSet)
        .reduce(_ ++ _)
      logger.trace("Table.FromRecords -> " + fields.toString)
      fields
    case `Table.FromRows`(_ :: TableType(FieldSpecificationList(fieldSpecs)) :: _) =>
      val fields = fieldSpecs.map(_.identifier.id).toSet
      logger.trace("Table.FromRows -> " + fields.toString)
      fields
    case `Table.Group`(_ :: (key: ListLiteral) :: (aggregatedColumns: ItemList) :: _) =>
      val fields = Arguments.listLiteralToList(key).toSet ++ Arguments.itemListToList(aggregatedColumns).toSet
      logger.trace("Table.Group -> " + fields.toString)
      fields
    case `Table.NestedJoin`(table1 :: _ :: _ :: _ :: TextLiteral(newColumnName) :: _ :: _) =>
      val existingFields = extractFields(table1)
      val fields = existingFields + newColumnName
      logger.trace("Table.NestedJoin -> " + fields.toString)
      fields
    case `Table.RemoveColumns`(table :: ListLiteral(columns) :: _) =>
      val fieldsToRemove = columns.map(Arguments.itemToString).toSet
      val existingFields = extractFields(table)
      val fields = existingFields -- fieldsToRemove
      logger.trace("Table.RemoveColumns -> " + fields.toString)
      fields
    case `Table.RemoveColumns`(table :: TextLiteral(column) :: _) =>
      val fieldsToRemove = Set(column)
      val existingFields = extractFields(table)
      val fields = existingFields -- fieldsToRemove
      logger.trace("Table.RemoveColumns -> " + fields.toString)
      fields
    case `Table.RenameColumns`(table :: ListLiteral(renames) :: _) =>
      val renameMap = Arguments.listLiteralToMap(renames)
      val fieldsToAdd = renameMap.values
      val fieldsToRemove = renameMap.keys
      val existingFields = extractFields(table)
      val fields = existingFields -- fieldsToRemove ++ fieldsToAdd
      logger.trace("Table.RenameColumns -> " + fields.toString)
      fields
    case `Table.ReplaceValue`(table :: _) =>
      val fields = extractFields(table)
      logger.trace("Table.ReplaceValue -> " + fields.toString)
      fields
    case `Table.SelectColumns`(_ :: ListLiteral(columns) :: _) =>
      val fields = columns.map(_.toString).toSet
      logger.trace("Table.SelectColumns -> " + fields.toString)
      fields
    case `Table.SelectRows`(table :: _) =>
      val fields = extractFields(table)
      logger.trace("Table.SelectRows -> " + fields.toString)
      fields
    case `Table.Sort`(table :: _) =>
      extractFields(table)
    case `Table.TransformColumnTypes`(table :: ItemList(typeTransformations) :: _) =>
      val map = Arguments.itemListToMap(typeTransformations)
      val existingFields = extractFields(table)
      val fieldsToAdd = map.keys.toSet
      val fields = existingFields ++ fieldsToAdd
      logger.trace("Table.TransformColumnTypes -> " + fields.toString)
      fields
    case `Value.NativeQuery`(_ :: TextLiteral(q) :: _) =>
      logger.debug(s"Value.NativeQuery(${q.replaceAll("\\p{Space}+", " ").trim}) -> ()")
      Set.empty // TODO: Parse SQL queries to obtain field names
    case ItemSelection(source: DataAccessFunction, selection) =>
      logger.trace(s"$source $selection -> ()")
      Set.empty
    case fn: DataAccessFunction =>
      logger.trace(s"$fn -> ()")
      Set.empty
    case fn: LibraryFunction =>
      logger.warn(s"$fn -> ()")
      Set.empty
    case other =>
      throw new IllegalArgumentException("Unhandled function: " + other.toString)
  }
}
