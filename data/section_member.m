shared #"SN LastUpdate" = let
    Source = Sql.Database(server_datawarehouse, bd_datawarehouse),

    dwh_vFtLastUpdate= Source{[Schema="dwh",Item="Followers"]}[Data],
    #"Removed Other Columns" = Table.SelectColumns(dwh_vFtLastUpdate,{"Sys_dInsert"}),
    #"Renamed Columns" = Table.RenameColumns(#"Removed Other Columns",{{"Sys_dInsert", "LastUpdate"}}),
    #"Calculated Latest" = List.Max(#"Renamed Columns"[LastUpdate]),
    #"Converted to Table" = #table(1, {{#"Calculated Latest"}}),
    #"Renamed Columns1" = Table.RenameColumns(#"Converted to Table",{{"Column1", "LastUpdate"}}),
    #"Changed Type" = Table.TransformColumnTypes(#"Renamed Columns",{{"LastUpdate", type datetime}})
in
    #"Renamed Columns1";
