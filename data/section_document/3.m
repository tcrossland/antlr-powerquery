section Section1;

shared País = let
    Source = Sql.Database(server_datawarehouse, bd_datawarehouse),
    dwh_vDimCountry = Source{[Schema="dwh",Item="vDimCountry"]}[Data],
    #"Renamed Columns" = Table.RenameColumns(dwh_vDimCountry,{{"Country_Id", "País - Id"}, {"Country_Name", "País"}, {"Continent_ES", "Continente"}, {"Population", "Población"}})
in
    #"Renamed Columns";

shared Medidas = let
    Source = Sql.Database(server_datawarehouse, bd_datawarehouse),
    dwh_Measure = Source{[Schema="dwh",Item="Measure"]}[Data],
    #"Filtered Rows" = Table.SelectRows(dwh_Measure, each (_[Measure_Type] = "Google analytics")),
    #"Removed Columns" = Table.RemoveColumns(#"Filtered Rows",{"Measure_Type"}),

    #"Renamed Columns" = Table.RenameColumns(#"Removed Columns",{{"Measure_Id", "Medida - Id"}, {"Measure_Name", "Medida"}})
in
    #"Renamed Columns";

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

[ Description = "Name of the dwh database server, ie: ll1tseunesqlentities.database.windows.net" ]
shared server_datawarehouse = "ll1preunesqlentities.database.windows.net" meta [IsParameterQuery=true, Type="Text", IsParameterQueryRequired=true];

[ Description = "Name of the dwh database, ie: ll1tseunesdbentities" ]
shared bd_datawarehouse = "ll1preunesdbentities" meta [IsParameterQuery=true, Type="Text", IsParameterQueryRequired=true];
