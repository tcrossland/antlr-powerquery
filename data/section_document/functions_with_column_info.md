** #table(columns as any, rows as any) as any
DataLake.Contents(url as text, optional options as nullable record) as table
Json.Document(jsonText as any, optional encoding as nullable number) as any  
Sql.Database(**server** as text, **database** as text, optional **options** as nullable record) as table
** Table.AddColumn(table as table, newColumnName as text, columnGenerator as function,  optional columnType as nullable type) as table  
** Table.Combine(tables as list, optional columns as any) as table
** Table.DuplicateColumn(**table** as table, **columnName** as text,** newColumnName** as text, optional **columnType** as nullable type) as table
** Table.ExpandTableColumn(table as table, column as text, columnNames as list, optional newColumnNames as nullable list) as table  
** Table.FromRecords(records as list, optional columns as any, optional missingField as nullable number) as table
** Table.FromRows(rows as list, optional columns as any) as table  
** Table.Group(table as table, key as any, aggregatedColumns as list, optional groupKind as nullable number, optional comparer as nullable function) as table  
** Table.NestedJoin(table1 as table, key1 as any, table2 as any, key2 as any, newColumnName as text, optional joinKind as nullable number, optional keyEqualityComparers as nullable list) as table
** Table.RemoveColumns(table as table, columns as any, optional missingField as nullable number) as table  
** Table.RenameColumns(table as table, renames as list, optional missingField as nullable number) as table  
Table.ReplaceValue(table as table, oldValue as any, newValue as any,replacer as function, columnsToSearch as {Text}) as table  
** Table.SelectColumns(table as table, columns as any, optional missingField as any) as table  
Table.SelectRows(table as table, condition as function) as table  
Table.Sort(table as table, optional comparisonCriteria as any) as table  
Table.TransformColumnTypes(table as table, typeTransformations as list, optional culture as nullable text) as table  
Value.NativeQuery(optional target as nullable any, query as text, optional parameters as nullable any, optional options as nullable record) as nullable any
