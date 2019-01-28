section Section1;

shared País = let
    Source = Sql.Database(server_datawarehouse, bd_datawarehouse),
    dwh_vDimCountry = Source{[Schema="dwh",Item="vDimCountry"]}[Data],
    #"Renamed Columns" = Table.RenameColumns(dwh_vDimCountry,{{"Country_Id", "País - Id"}, {"Country_Name", "País"}, {"Continent_ES", "Continente"}, {"Population", "Población"}})
in
    #"Renamed Columns";

[ Description = "Name of the dwh database server, ie: ll1tseunesqlentities.database.windows.net" ]
shared server_datawarehouse = "ll1preunesqlentities.database.windows.net" meta [IsParameterQuery=true, Type="Text", IsParameterQueryRequired=true];

[ Description = "Name of the dwh database, ie: ll1tseunesdbentities" ]
shared bd_datawarehouse = "ll1preunesdbentities" meta [IsParameterQuery=true, Type="Text", IsParameterQueryRequired=true];
