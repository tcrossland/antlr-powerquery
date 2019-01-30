section Section1;

shared Cadena = let
    Source = Sql.Database(server_datawarehouse, bd_datawarehouse),
    dwh_vDimChannel = Source{[Schema="dwh",Item="vDimChannel"]}[Data],
    #"Renamed Columns" = Table.RenameColumns(dwh_vDimChannel,{{"Channel_Id", "Cadena - Id"}, {"Channel_Name", "Cadena"}})
in
    #"Renamed Columns";

shared Competición = let
    Source = Sql.Database(server_datawarehouse, bd_datawarehouse),
    dwh_vDimCompetition = Source{[Schema="dwh",Item="vDimCompetition"]}[Data],
    #"Renamed Columns" = Table.RenameColumns(dwh_vDimCompetition,{{"Competition_Id", "Competición - Id"}, {"Competition_Name", "Competición"}})
in
    #"Renamed Columns";

shared País = let
    Source = Sql.Database(server_datawarehouse, bd_datawarehouse),
    dwh_vDimCountry = Source{[Schema="dwh",Item="vDimCountry"]}[Data],
    #"Renamed Columns" = Table.RenameColumns(dwh_vDimCountry,{{"Country_Id", "País - Id"}, {"Country_Name", "País"}, {"Continent_ES", "Continente"}, {"Population", "Población"}})
in
    #"Renamed Columns";

shared #"Fecha partido" = let
    Source = Sql.Database(server_datawarehouse, bd_datawarehouse),
    dwh_vDimDate_Match = Source{[Schema="dwh",Item="vDimDate_Match"]}[Data],
    #"Renamed Columns" = Table.RenameColumns(dwh_vDimDate_Match,{{"DateMatch_Id", "F. partido - Id"}, {"DateMatch_Name", "Fecha partido"}, {"DateMatch_WeekDayName", "Día semana"}, {"DateMatch_MonthOfYear", "F. partido - Mes del año"}, {"DateMatch_Month", "F. partido - Mes"}, {"DateMatch_QuarterOfYear", "F. partido - Trimestre del año"}, {"DateMatch_Quarter", "F. partido - Trimestre"}, {"DateMatch_Year", "F. partido - Año"}, {"DateMatch_WeekDayNum", "F. partido - Num día semana"}, {"DateMatch_MonthNum", "F. partido - Num mes"}, {"DateMatch_WeekDayAbrev", "F. partido - Día sem"}})
in
    #"Renamed Columns";

shared #"Fecha programa" = let
    Source = Sql.Database(server_datawarehouse, bd_datawarehouse),
    dwh_vDimDate_Program = Source{[Schema="dwh",Item="vDimDate_Program"]}[Data],
    #"Renamed Columns" = Table.RenameColumns(dwh_vDimDate_Program,{{"DateProgram_Id", "Fecha programa - Id"}, {"DateProgram_Name", "Fecha programa"}, {"DateProgram_WeekDayName", "Fecha programa - Día semana"}, {"DateProgram_MonthOfYear", "Fecha programa - Mes del año"}, {"DateProgram_Month", "Fecha programa - Mes"}, {"DateProgram_QuarterOfYear", "Fecha programa - Trimestre del año"}, {"DateProgram_Quarter", "Fecha programa - Trimestre"}, {"DateProgram_Year", "Fecha programa - Año"}, {"DateProgram_WeekDayNum", "Fecha programa - Num día semana"}, {"DateProgram_MonthNum", "Fecha programa - Num mes"}})
in
    #"Renamed Columns";

shared Difusión = let
    Source = Sql.Database(server_datawarehouse, bd_datawarehouse),
    dwh_vDimIsLive = Source{[Schema="dwh",Item="vDimIsLive"]}[Data],
    #"Renamed Columns" = Table.RenameColumns(dwh_vDimIsLive,{{"IsLive_Id", "Difusión - Id"}, {"IsLive_Name", "Difusión"}})
in
    #"Renamed Columns";

shared #"Es partido" = let
    Source = Sql.Database(server_datawarehouse, bd_datawarehouse),
    dwh_vDimIsMatch = Source{[Schema="dwh",Item="vDimIsMatch"]}[Data],
    #"Renamed Columns" = Table.RenameColumns(dwh_vDimIsMatch,{{"IsMatch_Id", "Es partido - Id"}, {"IsMatch_Name", "Es partido"}})
in
    #"Renamed Columns";

shared Partido = let
    Source = Sql.Database(server_datawarehouse, bd_datawarehouse),
    dwh_vDimMatch = Value.NativeQuery(
        Source, "
SELECT m.* 
FROM dwh.vDimMatch m
WHERE m.Season_Id >= 2016
AND m.Competition_Id = 1 -- Solo Liga Santander
"),
    #"Renamed Columns" = Table.RenameColumns(dwh_vDimMatch,{{"Match_Id", "Partido - Id"}, {"Match_OptaCode", "Partido - OptaCode"}, {"Match_Name", "Partido - Nombre"}, {"Match_Date", "Partido - Fecha"}, {"Match_ShortName", "Partido - Nombre corto"}, {"Match_NickName", "Partido"}, {"HomeTeam_Id", "Equipo local -Id"}, {"VisitorTeam_Id", "Equipo visitante - Id"}, {"Encuentro_Id", "Encuentro - Id"}, {"Match_NickName_Unique", "Partido ordenado"}})
in
    #"Renamed Columns";

shared Jornada = let
    Source = Sql.Database(server_datawarehouse, bd_datawarehouse),
    dwh_vDimMatchday = Source{[Schema="dwh",Item="vDimMatchday"]}[Data],
    #"Renamed Columns" = Table.RenameColumns(dwh_vDimMatchday,{{"Matchday_Number", "Jornada"}, {"Matchday_Name", "Jornada - Nombre"}})
in
    #"Renamed Columns";

shared #"Relación partido-equipo" = let
    Source = Sql.Database(server_datawarehouse, bd_datawarehouse),
    dwh_vDimMatchTeamRelation = Value.NativeQuery(
        Source, "
SELECT m.* 
FROM dwh.vDimMatchTeamRelation m 
WHERE m.Season_Id >= 2016
AND m.Competition_Id = 1 -- Solo Liga Santander
"),
    #"Renamed Columns" = Table.RenameColumns(dwh_vDimMatchTeamRelation,{{"Match_Id", "Partido - Id"}, {"Team_Id1", "Equipo - Id"}})
in
    #"Renamed Columns";

shared Temporada = let
    Source = Sql.Database(server_datawarehouse, bd_datawarehouse),
    dwh_vDimSeason = Source{[Schema="dwh",Item="vDimSeason"]}[Data],
    #"Renamed Columns" = Table.RenameColumns(dwh_vDimSeason,{{"Season_Id", "Temporada - Id"}, {"Season_Name", "Temporada"}, {"PreviousSeason_Id", "Temporada ant - Id"}})
in
    #"Renamed Columns";

shared Equipo = let
    Source = Sql.Database(server_datawarehouse, bd_datawarehouse),
    dwh_vDimTeam = Value.NativeQuery(
            Source, "
SELECT DISTINCT t.* 
FROM dwh.vDimTeam t
  INNER JOIN dwh.vDimMatchTeamRelation m ON t.Team_Id = m.Team_Id1
WHERE m.Season_Id >= 2016
AND m.Competition_Id = 1 -- Solo Liga Santander
"
),
    #"Renamed Columns" = Table.RenameColumns(dwh_vDimTeam,{{"Team_Id", "Equipo - Id"}, {"Team_Name", "Equipo - Nombre"}, {"Team_ShortName", "Equipo - Abreviatura"}, {"Team_Nickname", "Equipo"}, {"Team_LogoPath", "Equipo - Ruta logo"}, {"Team_MediumName", "Equipo - Nombre corto"}})
in
    #"Renamed Columns";

shared #"Equipo local" = let
    Source = Equipo,
    #"Renamed Columns" = Table.RenameColumns(Source,{{"Equipo - Id", "Equipo local - Id"}, {"Equipo - Nombre", "Equipo local - Nombre"}, {"Equipo - Abreviatura", "Equipo local - Abreviatura"}, {"Equipo", "Equipo local"}, {"Equipo - Ruta logo", "Equipo local - Ruta logo"}, {"Equipo - Nombre corto", "Equipo local - Nombre corto"}})
in
    #"Renamed Columns";

shared #"Equipo visitante" = let
    Source = Equipo,
    #"Renamed Columns" = Table.RenameColumns(Source,{{"Equipo - Id", "Equipo visitante - Id"}, {"Equipo - Nombre", "Equipo visitante - Nombre"}, {"Equipo - Abreviatura", "Equipo visitante - Abreviatura"}, {"Equipo", "Equipo visitante "}, {"Equipo - Ruta logo", "Equipo visitante - Ruta logo"}, {"Equipo - Nombre corto", "Equipo visitante - Nombre corto"}})
in
    #"Renamed Columns";

shared #"Hora partido" = let
    Source = Sql.Database(server_datawarehouse, bd_datawarehouse),
    dwh_vDimTime_Match = Source{[Schema="dwh",Item="vDimTime_Match"]}[Data],
    #"Renamed Columns" = Table.RenameColumns(dwh_vDimTime_Match,{{"TimeMatch_Id", "Hora partido - Id"}, {"TimeMatch_Name", "Hora HH:MM"}, {"TimeMatch_Hour", "Hora partido"}, {"TimeMatch_HourRange", "Rango horas"}})
in
    #"Renamed Columns";

shared #"Audiencia TV" = let
    Source = Sql.Database(server_datawarehouse, bd_datawarehouse),
    dwh_vFtTVAudience = Source{[Schema="dwh",Item="vFtTVAudience_International"]}[Data],
    #"Renamed Columns" = Table.RenameColumns(dwh_vFtTVAudience,{{"DateProgram_Id", "Fecha programa - Id"}, {"DateMatch_Id", "Fecha partido - Id"}, {"TimeMatch_Id", "Hora partido - Id"}, {"Competition_Id", "Competición - Id"}, {"Season_Id", "Temporada - Id"}, {"Matchday_Number", "Jornada - Id"}, {"Country_Id", "País - Id"}, {"Channel_Id", "Cadena - Id"}, {"Match_Id", "Partido - Id"}, {"HomeTeam_Id", "Equipo local - Id"}, {"VisitorTeam_Id", "Equipo visitante - Id"}, {"IsLive_Id", "Difusión - Id"}, {"IsMatch_Id", "Es partido - Id"}, {"Audience", "Audiencia TV"}, {"TVProgram", "Programa TV"}, {"Broadcaster_Id", "Broadcaster - Id"}, {"DurationRange_Id", "Duración programa - Id"}, {"Share", "Cuota"}, {"Contacts", "Contactos"}}),
    #"Only international audience" = Table.SelectRows(#"Renamed Columns", each [#"País - Id"] <> 724),
    #"Renamed Columns1" = Table.RenameColumns(#"Only international audience",{{"TimeProgram_Id", "Hora programa - Id"}})
in
    #"Renamed Columns1";

shared Neteado = let
    Source = Sql.Database(server_datawarehouse, bd_datawarehouse),
    dwh_vDimNeteo = Source{[Schema="dwh",Item="vDimNeteo"]}[Data],
    #"Renamed Columns" = Table.RenameColumns(dwh_vDimNeteo,{{"Neteo", "Neteado"}})
in
    #"Renamed Columns";

shared Broadcaster = let
    Source = Sql.Database(server_datawarehouse, bd_datawarehouse),
    dwh_vDimBroadcaster = Source{[Schema="dwh",Item="vDimBroadcaster"]}[Data],
    #"Renamed Columns" = Table.RenameColumns(dwh_vDimBroadcaster,{{"Broadcaster_Name", "Broadcaster"}, {"Broadcaster_Id", "Broadcaster - Id"}}),
    #"All excepted KANTAR" = Table.SelectRows(#"Renamed Columns", each [#"Broadcaster - Id"] <> 0)
in
    #"All excepted KANTAR";

shared #"Duración programa TV" = let
    Source = Sql.Database(server_datawarehouse, bd_datawarehouse),
    dwh_vDimDurationRange = Source{[Schema="dwh",Item="vDimDurationRange"]}[Data],
    #"Renamed Columns" = Table.RenameColumns(dwh_vDimDurationRange,{{"DurationRange_Name", "Duración programa TV"}, {"DurationRange_Id", "Duración programa - Id"}, {"DurationRange_From", "Duración programa - Desde"}, {"DurationRange_To", "Duración programa - Hasta"}})
in
    #"Renamed Columns";

shared Medidas = let
    Source = Table.FromRows(Json.Document(Binary.Decompress(Binary.FromText("i45WMlHSUXIsTclMzUvOTFTITU3JTFSK1YlWMsUUVygoygcx8pViYwE=", BinaryEncoding.Base64), Compression.Deflate)), let _t = ((type text) meta [Serialized.Text = true]) in type table [#"Medida - Id" = _t, Medida = _t]),
    #"Changed Type" = Table.TransformColumnTypes(Source,{{"Medida - Id", Int64.Type}, {"Medida", type text}})
in
    #"Changed Type";

shared #"Grupo días" = let
    Source = Table.FromRows(Json.Document(Binary.Decompress(Binary.FromText("i45WMlTSAeOwYBcfKNNQKVYnWskIyAJh3wgvKMsYLG6MIW4KFjfBEDcHi5tiWmAEljDDlDABS5hjSpgpxcYCAA==", BinaryEncoding.Base64), Compression.Deflate)), let _t = ((type text) meta [Serialized.Text = true]) in type table [DayNumOfWeek = _t, #"Group Id" = _t, #"Group Nom" = _t, #"Group Order" = _t, DayOrderAlt = _t]),
    #"Changed Type" = Table.TransformColumnTypes(Source,{{"DayNumOfWeek", Int64.Type}, {"Group Id", Int64.Type}, {"Group Nom", type text}, {"Group Order", Int64.Type}}),
    #"Renamed Columns" = Table.RenameColumns(#"Changed Type",{{"DayNumOfWeek", "Num día semana"}, {"Group Id", "Id grupo días"}, {"Group Nom", "Grupo días"}, {"Group Order", "Orden grupo días"}})
in
    #"Renamed Columns";

shared #"Ultima Jornada" = let
    Source = Sql.Database(server_datawarehouse, bd_datawarehouse),
    dwh_vFtUltimaJornada = Source{[Schema="dwh",Item="vFtUltimaJornada"]}[Data],
    #"Only international audience" = Table.SelectRows(dwh_vFtUltimaJornada, each [Country_Id] <> 724)
in
    #"Only international audience";

shared #"Ult actualización" = let
    Source = Sql.Database(server_datawarehouse, bd_datawarehouse),
    dwh_vFtLastUpdate = Source{[Schema="dwh",Item="vFtLastUpdate"]}[Data],
    #"All excepted KANTAR" = Table.SelectRows(dwh_vFtLastUpdate, each [Broadcaster_Id] <> 0)
in
    #"All excepted KANTAR";

shared Competición_Logo = let
    Source = Table.FromRows(Json.Document(Binary.Decompress(Binary.FromText("rc47C4MwGIXh/5LZ3JR26GYviBBqcRUpqfmIgZBIEmt/fi9DO3R1O3CG5+06xFGGxpSmuKPUWp4izA5iksoEiH4OA0Rys/5GBh+ALMYpv0TiINHv/1qTD0lBNNpRK63REkfpknQKAh7x4K0P2IGWydz9dcvYgzNGJqdRn3UoXztBSPFO4Hnxh+MPXvxwvlldr6sS1/tTe2wbUeJDI5qWXM4V6vsn", BinaryEncoding.Base64), Compression.Deflate)), let _t = ((type text) meta [Serialized.Text = true]) in type table [#"Competición - Id" = _t, #"Competición - Logo" = _t]),
    #"Changed Type" = Table.TransformColumnTypes(Source,{{"Competición - Id", Int64.Type}, {"Competición - Logo", type text}}),
    #"Renamed Columns" = Table.RenameColumns(#"Changed Type",{{"Competición - Id", "Competición"}})
in
    #"Renamed Columns";

shared RefTypeOrder = let
    Source = Table.FromRows(Json.Document(Binary.Decompress(Binary.FromText("i45WckwuKU3MUdJRMlKK1YlWci0szSxLzEnNK0kFihkqxcYCAA==", BinaryEncoding.Base64), Compression.Deflate)), let _t = ((type text) meta [Serialized.Text = true]) in type table [RefType = _t, Order = _t]),
    #"Changed Type" = Table.TransformColumnTypes(Source,{{"RefType", type text}, {"Order", Int64.Type}})
in
    #"Changed Type";

[ Description = "Name of the dwh database server, ie: ll1dveunesqlentities.database.windows.net" ]
shared server_datawarehouse = "ll1preunesqlentities.database.windows.net" meta [IsParameterQuery=true, Type="Text", IsParameterQueryRequired=true];

[ Description = "Name of the dwh database, ie: ll1dveunesdbentities" ]
shared bd_datawarehouse = "ll1preunesdbentities" meta [IsParameterQuery=true, Type="Text", IsParameterQueryRequired=true];

shared #"Partido ordenado medida" = let
    Source = Sql.Database(server_datawarehouse, bd_datawarehouse),
    dwh_vDimMatchOrdered = Value.NativeQuery(
        Source, "
SELECT aud.*
FROM dwh.vDimMatchOrdered_Audience aud
  INNER JOIN dwh.vDimMatch m ON aud.Match_Id = m.Match_Id
  --INNER JOIN dwh.vAudienceKantar_StartSeason s ON m.Season_Id >= s.StartSeason_Id
  --INNER JOIN dwh.vAudienceKantar_ValidCompetitions c ON m.Competition_Id = c.Competition_Id
WHERE m.Season_Id >= 2016
AND m.Competition_Id = 1 -- Solo Liga Santander
AND aud.Medida_Id IN (4, 5) -- Solo audiencia y audiencia media promedio
"),
    #"Renamed Columns" = Table.RenameColumns(dwh_vDimMatchOrdered,{{"Match_NickName_Unique", "Partido ordenado"}, {"Medida_Id", "Medida - Id"}, {"Match_Id", "Partido - Id"}})
in
    #"Renamed Columns";

shared #"Hora programa" = let
    Source = Sql.Database(server_datawarehouse, bd_datawarehouse),
    dwh_vDimTime_Match = Source{[Schema="dwh",Item="vDimTime_Match"]}[Data],
    #"Renamed Columns" = Table.RenameColumns(dwh_vDimTime_Match,{{"TimeMatch_Id", "Hora programa - Id"}, {"TimeMatch_Name", "Hora programa HH:MM"}, {"TimeMatch_Hour", "Hora programa"}, {"TimeMatch_HourRange", "Rango horas programa"}})
in
    #"Renamed Columns";

[ Description = "First 9 characters of the name of the environment where the reports are being deployed, ie: ll1dveune" ]
shared DeploymentEnvironment = "ll1preune" meta [IsParameterQuery=true, Type="Text", IsParameterQueryRequired=true];