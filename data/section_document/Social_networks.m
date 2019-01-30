section Section1;

shared País = let
    Source = Sql.Database(server_datawarehouse, bd_datawarehouse),
    dwh_vDimCountry = Source{[Schema="dwh",Item="vDimCountry"]}[Data],
    #"Renamed Columns" = Table.RenameColumns(dwh_vDimCountry,{{"Country_Id", "País - Id"}, {"Country_Name", "País"}, {"Continent_ES", "Continente"}, {"Population", "Población"}})
in
    #"Renamed Columns";

shared Medidas = let
    Source = Sql.Database(server_datawarehouse, bd_datawarehouse),
    dwh_Measure = Value.NativeQuery(
        Source, "
    SELECT d.Measure_Id, d.Measure_Name
    FROM dwh.Measure d
    WHERE Measure_Type = 'Social networks'
"),
    #"Renamed Columns" = Table.RenameColumns(dwh_Measure,{{"Measure_Id", "Medida - Id"}, {"Measure_Name", "Medida"}})
in
    #"Renamed Columns";

shared #"Ult actualización" = let
    Source = Sql.Database(server_datawarehouse, bd_datawarehouse),
    dwh_vFtLastUpdate = Value.NativeQuery(
            Source,
            "
SELECT MAX(Sys_dInsert) LastUpdate FROM dwh.Followers"
    )

in
    dwh_vFtLastUpdate;

[ Description = "Name of the dwh database server, ie: ll1dveunesqlentities.database.windows.net" ]
shared server_datawarehouse = "ll1preunesqlentities.database.windows.net" meta [IsParameterQuery=true, Type="Text", IsParameterQueryRequired=true];

[ Description = "Name of the dwh database, ie: ll1dveunesdbentities" ]
shared bd_datawarehouse = "ll1preunesdbentities" meta [IsParameterQuery=true, Type="Text", IsParameterQueryRequired=true];

[ Description = "First 9 characters of the name of the environment where the reports are being deployed, ie: ll1dveune" ]
shared DeploymentEnvironment = "ll1preune" meta [IsParameterQuery=true, Type="Text", IsParameterQueryRequired=true];

shared Cuenta = let
    Source = Sql.Database(server_datawarehouse, bd_datawarehouse),
    dwh_vDimSocialAccount = Value.NativeQuery(
            Source,
            "
            SELECT d.*, c.Code SocialAccount_Code
            FROM dwh.vDimSocialAccount d
              INNER JOIN dwh.SocialNetworkAccount c ON d.SocialAccount_Id = c.Id
"
    ),

    #"Renamed Columns" = Table.RenameColumns(dwh_vDimSocialAccount,{{"SocialAccount_Name", "Cuenta"}}),
    #"Merged Queries" = Table.NestedJoin(#"Renamed Columns",{"SocialAccount_Code"},CuentaNoMostrar,{"Cuenta"},"CuentaNoMostrar",JoinKind.LeftOuter),
    #"Expanded CuentaNoMostrar" = Table.ExpandTableColumn(#"Merged Queries", "CuentaNoMostrar", {"FlagNoMostrar"}, {"FlagNoMostrar"}),
    #"Renamed Columns1" = Table.RenameColumns(#"Expanded CuentaNoMostrar",{{"FlagNoMostrar", "FlagMostrarCuenta"}}),
    #"Replaced Value" = Table.ReplaceValue(#"Renamed Columns1",1,0,Replacer.ReplaceValue,{"FlagMostrarCuenta"}),
    #"Replaced Value1" = Table.ReplaceValue(#"Replaced Value",null,1,Replacer.ReplaceValue,{"FlagMostrarCuenta"})
in
    #"Replaced Value1";

shared Entidad = let
    Source = Sql.Database(server_datawarehouse, bd_datawarehouse),
    dwh_vDimSocialEntity = Source{[Schema="dwh",Item="vDimSocialEntity"]}[Data],
    #"Renamed Columns" = Table.RenameColumns(dwh_vDimSocialEntity,{{"SocialEntity_Name", "Entidad"}}),

// Tipo= 1 --> Competición
// Tipo= 2 --> Club
    #"Added Conditional Column" = Table.AddColumn(#"Renamed Columns", "TipoEntidad", each if [Entidad] = "Bundesliga" 
            or [Entidad] = "LaLiga Santander" 
            or [Entidad] = "Ligue 1" 
            or [Entidad] = "Premier League" 
            or [Entidad] = "Serie A" 

            then "Competición" else "Club"),
    #"Merged Queries" = Table.NestedJoin(#"Added Conditional Column",{"Entidad"},EntidadMostrar,{"Entidad"},"EntidadMostrar",JoinKind.LeftOuter),
    #"Expanded EntidadMostrar" = Table.ExpandTableColumn(#"Merged Queries", "EntidadMostrar", {"FlagMostrarEnInforme"}, {"FlagMostrarEnInforme"}),
    #"Replaced Value" = Table.ReplaceValue(#"Expanded EntidadMostrar",null,0,Replacer.ReplaceValue,{"FlagMostrarEnInforme"}),
    #"Renamed Columns1" = Table.RenameColumns(#"Replaced Value",{{"FlagMostrarEnInforme", "FlagMostrarEntidad"}})
in
    #"Renamed Columns1";

shared #"Red social" = let
    Source = Sql.Database(server_datawarehouse, bd_datawarehouse),
    dwh_vDimSocialNetwork = Source{[Schema="dwh",Item="vDimSocialNetwork"]}[Data],
    #"Renamed Columns" = Table.RenameColumns(dwh_vDimSocialNetwork,{{"SocialNetwork_Name", "Red social"}})
in
    #"Renamed Columns";

shared Seguidores = let
    Source = Sql.Database(server_datawarehouse, bd_datawarehouse),
    dwh_vFtFollowers = Source{[Schema="dwh",Item="vFtFollowers"]}[Data],
    #"Renamed Columns" = Table.RenameColumns(dwh_vFtFollowers,{{"NewFollowers", "Nuevos seguidores"}})
in
    #"Renamed Columns";

shared #"Seguidores por país" = let
    Source = Sql.Database(server_datawarehouse, bd_datawarehouse),
    dwh_vFtFollowersByCountry = Value.NativeQuery(
            Source,
            "
SELECT ft.*
, d.WeekOfSeason_Id Week_Id, d.WeekNumOfSeason
, RIGHT(d.WeekOfSeason_Id, 2) + ' (' + CONVERT(VARCHAR(8), WeekOfSeasonBeginDate, 3) + '-' + CONVERT(VARCHAR(8), WeekOfSeasonEndDate, 3) + ')' Week_Name
FROM dwh.vFtFollowersByCountry ft
  INNER JOIN dwh.DimDate d ON ft.Date_Id = d.DimDateID
WHERE ft.Followers > 0

"
    )


in
    dwh_vFtFollowersByCountry;

shared Engagement = let
    Source = Sql.Database(server_datawarehouse, bd_datawarehouse),
    dwh_vFtSocialEngagement = Source{[Schema="dwh",Item="vFtSocialEngagement"]}[Data],
    #"Renamed Columns" = Table.RenameColumns(dwh_vFtSocialEngagement,{{"PostDate", "PostDate"}})
in
    #"Renamed Columns";

shared Fecha = let
    Source = Sql.Database(server_datawarehouse, bd_datawarehouse),
    dwh_vDimDate = Value.NativeQuery(
        Source, "
    SELECT d.*
    FROM dwh.vDimDate d
      INNER JOIN dwh.vSocialNetworks_StartYear s ON d.Year_Num >= s.StartYear
    WHERE d.Year_Num <= YEAR(GETDATE())
")
in
    dwh_vDimDate;

shared SocialNetwork_Logo = let
    Source = Table.FromRows(Json.Document(Binary.Decompress(Binary.FromText("vdBRagIxEMbxq0helQRfPYClKEVQFFlkSbJDGowzSzJprt+l2iVeIG8D8/D783Wd2GoLhuguVuKbeUwbpUJYDz+QERLrwUdIlKOFJE0gIy1FkMXjQCVJBFbzf7pGijxA8g7VkazX4Qu4ULwntSdH/b/VmyJHdOK26sQnToqL+tEiYMbqgqNHvbiAN9Qi4Q+q+VPxzBBb2C+q1q+UORtoob+oWv8gcgGWLfQndQg5vY0PaAG5yfhPqtbPuxbweTebt18=", BinaryEncoding.Base64), Compression.Deflate)), let _t = ((type text) meta [Serialized.Text = true]) in type table [SocialNetork_Name = _t, SocialNetwork_Logo = _t]),
    #"Changed Type" = Table.TransformColumnTypes(Source,{{"SocialNetork_Name", type text}, {"SocialNetwork_Logo", type text}}),

    #"Replaced Value" = Table.ReplaceValue(#"Changed Type","ll1dveune",DeploymentEnvironment,Replacer.ReplaceText,{"SocialNetwork_Logo"})

in
    #"Replaced Value";

shared Entidad_Logo = let
    Source = Table.FromRows(Json.Document(Binary.Decompress(Binary.FromText("vZZBbuIwFIavYrFuoWHa0nYHYZhZpKNqULtB1eiRvAnWmDiynaAeZ5Ys5wxcbJ6D7ZQDOAukSE74Ptm/f3uzGb0o3HNULEMoGxxdjXbG1PppMhEiKVpsKtQGCq5Qy0blqMdbIbfjXCocH3hVyIMeV2gmYZyeaqlMgZqX1WQtcw7iB5qDVH/0JJOl/OWIZ+C4rkqCTumXjN6vNqMMMl4CW0NloCpQDWF0ZjqVJKgsGhLQgoaGkOhpTuRLEJkbcToanktWIHuGQvEishEYgRboVB6CyiplC6DPhaxiz8rWc5zEfZ8RTslhySDRsKjEGdwGg+fTXwEU03QVWWIPluOjaSNx0wn8RBDDREER6XrfkZzGLEzDesm+clqnyApoGX4O+qpYo+LI5kPEoEPNncLdJ4OWCwFslUaW0GeQE3gMAm8gsKI34wexdSS/DDe9gzVTNiYDWASW9+jretl9x1vJ5gLa01HH7kii0F84j9uwNedm15UnS0Wzjd7TZ5a3uLssiAWNaSpsIfc1Px1jF7aleZO+rVMUBuzJ9cZLGVkhtyyvMAuT0UeDNDLaLVI1p3+xD7DCU73QQ786KTWnrqH6kCJ2eTqMl3gMEt/QwG+Mv2nLjuNvejc9nys63eOXZ9lxPD8JfDq9vjeo89g52HUQz58G/uuSsqjZC4g9xC4rAfq67kDeo79LUBYzLKGKX5nCYkJnTvvOzLClCz+y12V0gw7kDT71JXxIRsepwByq2DWlCOYV7i8r276JBQxyq9OO5VVmlyp2NqCQIvoVsw0gb+Ka8v0/", BinaryEncoding.Base64), Compression.Deflate)), let _t = ((type text) meta [Serialized.Text = true]) in type table [Entidad = _t, Entidad_Logo = _t, Entidad_orden = _t, FlagMostrarEnInforme = _t]),
    #"Changed Type" = Table.TransformColumnTypes(Source,{{"Entidad", type text}, {"Entidad_Logo", type text}}),

    #"Replaced Value" = Table.ReplaceValue(#"Changed Type","ll1dveune",DeploymentEnvironment,Replacer.ReplaceText,{"Entidad_Logo"})

in
    #"Replaced Value";

shared TipoEntidad_Logo = let
    Source = Table.FromRows(Json.Document(Binary.Decompress(Binary.FromText("tc6xDQIxDIXhXVIfiWgpoaehPF1xSazDwthR7JDBGIHFSIEQC9A96S++N8/uJPcChglfT3aTu5oVPYRAtM8PaAxqa8YKKq0mUB9Jok9SwXfkLF09g4VvH6tItQyKG4eLJFzpDNal3jR8KEPh3VEo+8KbW6bxgVr8tz0I/VGXNw==", BinaryEncoding.Base64), Compression.Deflate)), let _t = ((type text) meta [Serialized.Text = true]) in type table [TipoEntidad = _t, TipoEntidad_Logo = _t]),
    #"Changed Type" = Table.TransformColumnTypes(Source,{{"TipoEntidad", type text}, {"TipoEntidad_Logo", type text}}),

    #"Replaced Value" = Table.ReplaceValue(#"Changed Type","ll1dveune",DeploymentEnvironment,Replacer.ReplaceText,{"TipoEntidad_Logo"})
in
    #"Replaced Value";

shared EntidadMostrar = let
    Source = Table.FromRows(Json.Document(Binary.Decompress(Binary.FromText("XY5BCoNADEWvEmbtxiOorSsLpYIbcZE6QQJxLHHsnTyHF+vYwihd/veS/LStuSuNTAoV4bCQSUxquqQ1FVY8INToPDpLGkW+hDhLkBFlXrbVcz+BJbihVbbRlQXkqD3J5I6FcHohSGN+EMr/Yn2BKz/xKK5JmSA75TeLIJRFRA0KuZ4RivJg+5Dq3nCi38acPM/hPZnGF2/rT3Yf", BinaryEncoding.Base64), Compression.Deflate)), let _t = ((type text) meta [Serialized.Text = true]) in type table [Entidad = _t, FlagMostrarEnInforme = _t]),
    #"Changed Type" = Table.TransformColumnTypes(Source,{{"FlagMostrarEnInforme", Int64.Type}})
in
    #"Changed Type";

shared CuentaNoMostrar = let
    Source = Table.FromRows(Json.Document(Binary.Decompress(Binary.FromText("nZPZboMwEEX/hedoZHsWPN+CIgTIoahJXLEo6t/XqSpaCVJCnn2OxneWoshOVRPqGN/LcG3P3fBWfvTh0oW+PIeqnUJp2Yp6o4igPjtkNjseimy8deOYoIeSQTQoLKD5Xkk8qO6VPIKbnTnTEJsmsV7uHLF1Ig5wBYyxPDV11TfhHEtLgndSiJPnkK3mguD3ax4VPL7giQI/zsMkLmnkmZTQgspTKBsB1qdQsQy/g+uuw1i1fXXZ+LgzSgZyfkXMCdgupr6l5epA3EL7k+i/t7mHpOCWxdda6NIeLM9gjSQPhmbyM07jVIetQNakAsLPbz+me2FyDG7HyXxLbCzkP1GOXw==", BinaryEncoding.Base64), Compression.Deflate)), let _t = ((type text) meta [Serialized.Text = true]) in type table [Cuenta = _t, FlagNoMostrar = _t]),
    #"Changed Type1" = Table.TransformColumnTypes(Source,{{"FlagNoMostrar", Int64.Type}})
in
    #"Changed Type1";