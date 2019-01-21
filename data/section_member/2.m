shared Fecha = let
    Source = Sql.Database(server_datawarehouse, bd_datawarehouse),

    dwh_vDimDate = Source{[Schema="dwh",Item="vDimDate"]}[Data],
    #"Filtered Rows" = Table.SelectRows(dwh_vDimDate, each [Year_Num] >= 2014 and [Year_Num] <= Date.Year(DateTime.LocalNow()))
in
    #"Filtered Rows";
