section Section1;

shared País = let
    Source = Sql.Database(server_datawarehouse, bd_datawarehouse),
    dwh_vDimCountry = Source{[Schema="dwh",Item="vDimCountry"]}[Data],
    #"Renamed Columns" = Table.RenameColumns(dwh_vDimCountry,{{"Country_Id", "País - Id"}, {"Country_Name", "País"}, {"Continent_ES", "Continente"}, {"Population", "Población"}})
in
    #"Renamed Columns";
