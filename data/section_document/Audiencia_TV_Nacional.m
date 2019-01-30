section Section1;

shared #"Rango edad" = let
    Source = Sql.Database(server_datawarehouse, bd_datawarehouse),
    dwh_vDimAgeRange = Source{[Schema="dwh",Item="vDimAgeRange"]}[Data],
    #"Renamed Columns" = Table.RenameColumns(dwh_vDimAgeRange,{{"AgeRange_Id", "Rango edad - Id"}, {"AgeRange_Name", "Rango edad"}, {"AgeRange_From", "Rango edad - Desde"}, {"AgeRange_To", "Rango edad - Hasta"}})
in
    #"Renamed Columns";

shared Cadena = let
    Source = Sql.Database(server_datawarehouse, bd_datawarehouse),
    dwh_vDimChannel = Source{[Schema="dwh",Item="vDimChannel"]}[Data],
    #"Renamed Columns" = Table.RenameColumns(dwh_vDimChannel,{{"Channel_Id", "Cadena - Id"}, {"Channel_Name", "Cadena"}, {"Channel_Type", "Tipo cadena"}})
in
    #"Renamed Columns";

shared Competición = let
    Source = Sql.Database(server_datawarehouse, bd_datawarehouse),
    dwh_vDimCompetition = Source{[Schema="dwh",Item="vDimCompetition"]}[Data],
    #"Renamed Columns" = Table.RenameColumns(dwh_vDimCompetition,{{"Competition_Id", "Competición - Id"}, {"Competition_Name", "Competición"}})
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
FROM dwh.vDimMatch  m
  INNER JOIN dwh.vAudienceKantar_StartSeason s ON m.Season_Id >= s.StartSeason_Id
  INNER JOIN dwh.vAudienceKantar_ValidCompetitions c ON m.Competition_Id = c.Competition_Id
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
            Source,
            "
SELECT m.* 
FROM dwh.vDimMatchTeamRelation m 
  INNER JOIN dwh.vAudienceKantar_StartSeason s ON m.Season_Id >= s.StartSeason_Id
  INNER JOIN dwh.vAudienceKantar_ValidCompetitions c ON m.Competition_Id = c.Competition_Id

"
),
    #"Renamed Columns" = Table.RenameColumns(dwh_vDimMatchTeamRelation,{{"Match_Id", "Partido - Id"}, {"Team_Id1", "Equipo1 - Id"}, {"Segment_Code1", "Segmento1"}, {"Team_Id2", "Equipo2 - Id"}, {"Segment_Code2", "Segmento2"}})
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
  INNER JOIN dwh.vAudienceKantar_StartSeason s ON m.Season_Id >= s.StartSeason_Id
  INNER JOIN dwh.vAudienceKantar_ValidCompetitions c ON m.Competition_Id = c.Competition_Id"
),
    #"Renamed Columns" = Table.RenameColumns(dwh_vDimTeam,{{"Team_Id", "Equipo - Id"}, {"Team_Name", "Equipo - Nombre"}, {"Team_ShortName", "Equipo - Abreviatura"}, {"Team_Nickname", "Equipo"}, {"Team_LogoPath", "Equipo - Ruta logo"}, {"Team_MediumName", "Equipo - Nombre corto"}, {"CurrentSegment_Code", "Segmento"}})
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
    dwh_vFtTVAudience_National = Source{[Schema="dwh",Item="vFtTVAudience_National"]}[Data],
    #"Renamed Columns" = Table.RenameColumns(dwh_vFtTVAudience_National,{{"DateProgram_Id", "Fecha programa - Id"}, {"DateMatch_Id", "Fecha partido - Id"}, {"TimeMatch_Id", "Hora partido - Id"}, {"Competition_Id", "Competición - Id"}, {"Season_Id", "Temporada - Id"}, {"Matchday_Number", "Jornada - Id"}, {"Channel_Id", "Cadena - Id"}, {"AmbitoGeografico_Id", "Ámbito geográfico - Id"}, {"AgeRange_Id", "Rango edad - Id"}, {"Match_Id", "Partido - Id"}, {"HomeTeam_Id", "Equipo local - Id"}, {"VisitorTeam_Id", "Equipo visitante - Id"}, {"IsLive_Id", "Difusión - Id"}, {"IsMatch_Id", "Es partido - Id"}, {"Audience", "Audiencia TV"}, {"TVProgram", "Programa TV"}, {"DurationRange_Id", "Duración programa - Id"}, {"Share", "Cuota"}, {"Contacts", "Contactos"}, {"ChannelType_Name", "Tipo cadena"}, {"AdjustedAudience", "Audiencia reparto"}})

in
    #"Renamed Columns";

shared #"Ámbito geográfico" = let
    Source = Sql.Database(server_datawarehouse, bd_datawarehouse),
    dwh_vDimAmbitoGeografico = Source{[Schema="dwh",Item="vDimAmbitoGeografico"]}[Data],
    #"Renamed Columns" = Table.RenameColumns(dwh_vDimAmbitoGeografico,{{"AmbitoGeografico_Id", "Ámbito geográfico - Id"}, {"AmbitoGeografico_Name", "Ámbito geográfico"}})
in
    #"Renamed Columns";

shared Neteado = let
    Source = Sql.Database(server_datawarehouse, bd_datawarehouse),
    dwh_vDimNeteo = Source{[Schema="dwh",Item="vDimNeteo"]}[Data],
    #"Renamed Columns" = Table.RenameColumns(dwh_vDimNeteo,{{"Neteo", "Neteado"}})
in
    #"Renamed Columns";

shared #"Duración programa TV" = let
    Source = Sql.Database(server_datawarehouse, bd_datawarehouse),
    dwh_vDimDurationRange = Source{[Schema="dwh",Item="vDimDurationRange"]}[Data],
    #"Renamed Columns" = Table.RenameColumns(dwh_vDimDurationRange,{{"DurationRange_Name", "Duración programa TV"}, {"DurationRange_Id", "Duración programa - Id"}, {"DurationRange_From", "Duración programa - Desde"}, {"DurationRange_To", "Duración programa - Hasta"}})
in
    #"Renamed Columns";

shared Medidas = let
    Source = Sql.Database(server_datawarehouse, bd_datawarehouse),
    dwh_Measure = Source{[Schema="dwh",Item="Measure"]}[Data],
    #"Renamed Columns" = Table.RenameColumns(dwh_Measure,{{"Measure_Id", "Medida - Id"}, {"Measure_Name", "Medida"}})
in
    #"Renamed Columns";

shared #"Grupo días" = let
    Source = Table.FromRows(Json.Document(Binary.Decompress(Binary.FromText("i45WMlTSAeOwYBcfKNNQKVYnWskIyAJh3wgvKMsYLG6MIW4KFjfBEDcHi5tiWmAEljDDlDABS5hjSpgpxcYCAA==", BinaryEncoding.Base64), Compression.Deflate)), let _t = ((type text) meta [Serialized.Text = true]) in type table [DayNumOfWeek = _t, #"Group Id" = _t, #"Group Nom" = _t, #"Group Order" = _t, DayOrderAlt = _t]),
    #"Changed Type" = Table.TransformColumnTypes(Source,{{"DayNumOfWeek", Int64.Type}, {"Group Id", Int64.Type}, {"Group Nom", type text}, {"Group Order", Int64.Type}}),
    #"Renamed Columns" = Table.RenameColumns(#"Changed Type",{{"DayNumOfWeek", "Num día semana"}, {"Group Id", "Id grupo días"}, {"Group Nom", "Grupo días"}, {"Group Order", "Orden grupo días"}})
in
    #"Renamed Columns";

shared #"Ultima Jornada" = let
    Source = Sql.Database(server_datawarehouse, bd_datawarehouse),
    dwh_vFtUltimaJornada = Source{[Schema="dwh",Item="vFtUltimaJornada"]}[Data],
    #"Filtered Rows" = Table.SelectRows(dwh_vFtUltimaJornada, each [Country_Id] = 724),
    #"Renamed Columns" = Table.RenameColumns(#"Filtered Rows",{{"Country_Id", "País - Id"}})
in
    #"Renamed Columns";

shared #"Ult actualización" = let
    Source = Sql.Database(server_datawarehouse, bd_datawarehouse),
    dwh_vFtLastUpdate = Source{[Schema="dwh",Item="vFtLastUpdate"]}[Data]
in
    dwh_vFtLastUpdate;

shared Competición_Logo = let
    Source = Table.FromRows(Json.Document(Binary.Decompress(Binary.FromText("rc7dasIwHAXwVwm5tmlTmbjdVYwjUNMSu90UKbENNRDyL0nUvcceyReb+8C9gHeHcy5+p20xxTN8jHEKL2lqLY1Bn5wOUQ3G6wAn3+tADhYOpAevycW4AS6BOB3T+35LE/g46GBGl1plzaiSoFxUbtA+OSY9WPDJIss+njMyuRHvZy3OHw2XqvyGaT6/kxMEE80Zfmw6/8fp08P16rVCteRbJgu05u98x6+fAm3YlgkubhVDm7dmVZWIr5hcy6osujyjy66RhdjVhWSiYV39d/j36P4L", BinaryEncoding.Base64), Compression.Deflate)), let _t = ((type text) meta [Serialized.Text = true]) in type table [#"Competición - Id" = _t, #"Competición - Logo" = _t]),
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
  INNER JOIN dwh.vAudienceKantar_StartSeason s ON m.Season_Id >= s.StartSeason_Id
  INNER JOIN dwh.vAudienceKantar_ValidCompetitions c ON m.Competition_Id = c.Competition_Id
WHERE aud.Measure_Type IN ('Audiencia', 'Audiencia ajustada')

UNION ALL
SELECT p.Match_Id, p.Match_Name, q.Measure_Id, q.Measure_Name, q.Measure_Type
FROM 
	( 
		SELECT -1 Match_Id, 'Partido No Informado' Match_Name
	) p
  FULL OUTER JOIN (SELECT * FROM dwh.Measure WHERE Measure_Type IN ('Audiencia', 'Audiencia ajustada')) q ON 1= 1

"),
    #"Renamed Columns" = Table.RenameColumns(dwh_vDimMatchOrdered,{{"Match_NickName_Unique", "Partido ordenado"}, {"Medida_Id", "Medida - Id"}, {"Match_Id", "Partido - Id"}})
in
    #"Renamed Columns";

[ Description = "First 9 characters of the name of the environment where the reports are being deployed, ie: ll1dveune" ]
shared DeploymentEnvironment = "ll1preune" meta [IsParameterQuery=true, Type="Text", IsParameterQueryRequired=true];

shared #"Aud equivalente con cadena" = let
    Source = Sql.Database(server_datawarehouse, bd_datawarehouse),
    dwh_vFtTVAudience_EquivalentMatch_WithChannel = Source{[Schema="dwh",Item="vFtTVAudience_EquivalentMatch_WithChannel"]}[Data],

    #"Renamed Columns" = Table.RenameColumns(#"dwh_vFtTVAudience_EquivalentMatch_WithChannel",{{"ChannelType_Name", "Tipo cadena"}})
in
    #"Renamed Columns";

shared #"Tipo cadena" = let
    Source = Sql.Database(server_datawarehouse, bd_datawarehouse),
    dwh_vDimChannelType = Source{[Schema="dwh",Item="vDimChannelType"]}[Data],

    #"Renamed Columns" = Table.RenameColumns(#"dwh_vDimChannelType",{{"ChannelType_Name", "Tipo cadena"}})
in
    #"Renamed Columns";

shared #"Población Rango edad - CA" = let
    Source = Sql.Database(server_datawarehouse, bd_datawarehouse),
    dwh_vDimAgerangeRegionPopulation = Source{[Schema="dwh",Item="vDimAgerangeRegionPopulation"]}[Data]
in
    dwh_vDimAgerangeRegionPopulation;

shared #"Segmento 1" = let
    Source = Sql.Database(server_datawarehouse, bd_datawarehouse),
    dwh_vDimClubSegment = Source{[Schema="dwh",Item="vDimClubSegment"]}[Data]
in
    dwh_vDimClubSegment;

shared #"Segmento 2" = let
    Source = Sql.Database(server_datawarehouse, bd_datawarehouse),
    dwh_vDimClubSegment = Source{[Schema="dwh",Item="vDimClubSegment"]}[Data]
in
    dwh_vDimClubSegment;

shared #"Equipo 2" = let
    Source = Sql.Database(server_datawarehouse, bd_datawarehouse),
    dwh_vDimTeam = Source{[Schema="dwh",Item="vDimTeam"]}[Data],
    #"Renamed Columns" = Table.RenameColumns(dwh_vDimTeam,{{"Team_Id", "Equipo - Id"}, {"Team_Name", "Equipo - Nombre"}, {"Team_ShortName", "Equipo - Abreviatura"}, {"Team_Nickname", "Equipo"}, {"Team_LogoPath", "Equipo - Ruta logo"}, {"Team_MediumName", "Equipo - Nombre corto"}, {"CurrentSegment_Code", "Segmento"}})
in
    #"Renamed Columns";

shared #"Audiencia minuto - Total" = let
    Source = Sql.Database(server_datawarehouse, bd_datawarehouse),
    dwh_vFtAudienceMinuteToMinute_Total = Source{[Schema="dwh",Item="vFtAudienceMinuteToMinute_Total"]}[Data],
    #"Renamed Columns" = Table.RenameColumns(dwh_vFtAudienceMinuteToMinute_Total,{{"Season_Id", "Temporada"}, {"Matchday_Number", "Jornada"}})
in
    #"Renamed Columns";

shared Franja = let
    Source = Sql.Database(server_datawarehouse, bd_datawarehouse),
    dwh_vDimFranja = Source{[Schema="dwh",Item="vDimFranja"]}[Data]
in
    dwh_vDimFranja;

shared #"Fecha min2min" = let
    Source = Sql.Database(server_datawarehouse, bd_datawarehouse),
    dwh_vDimDate_Match = Source{[Schema="dwh",Item="vDimDate_Match"]}[Data],
    #"Renamed Columns" = Table.RenameColumns(dwh_vDimDate_Match,{{"DateMatch_Id", "F. partido - Id"}, {"DateMatch_Name", "Fecha partido"}, {"DateMatch_WeekDayName", "Día semana"}, {"DateMatch_MonthOfYear", "F. partido - Mes del año"}, {"DateMatch_Month", "F. partido - Mes"}, {"DateMatch_QuarterOfYear", "F. partido - Trimestre del año"}, {"DateMatch_Quarter", "F. partido - Trimestre"}, {"DateMatch_Year", "F. partido - Año"}, {"DateMatch_WeekDayNum", "F. partido - Num día semana"}, {"DateMatch_MonthNum", "F. partido - Num mes"}, {"DateMatch_WeekDayAbrev", "F. partido - Día sem"}})
in
    #"Renamed Columns";

shared #"Competición min2min" = let
    Source = Sql.Database(server_datawarehouse, bd_datawarehouse),
    dwh_vDimCompetition = Source{[Schema="dwh",Item="vDimCompetition"]}[Data],
    #"Renamed Columns" = Table.RenameColumns(dwh_vDimCompetition,{{"Competition_Id", "Competición - Id"}, {"Competition_Name", "Competición"}}),
    #"Merged Queries" = Table.NestedJoin(#"Renamed Columns",{"Competición - Id"},Competición_Logo,{"Competición"},"Competición_Logo",JoinKind.LeftOuter),
    #"Expanded Competición_Logo1" = Table.ExpandTableColumn(#"Merged Queries", "Competición_Logo", {"Competición - Logo"}, {"Competición - Logo"})
in
    #"Expanded Competición_Logo1";

shared #"Jornada min2min" = let
    Source = Sql.Database(server_datawarehouse, bd_datawarehouse),
    dwh_vDimMatchday = Source{[Schema="dwh",Item="vDimMatchday"]}[Data],
    #"Renamed Columns" = Table.RenameColumns(dwh_vDimMatchday,{{"Matchday_Number", "Jornada"}, {"Matchday_Name", "Jornada - Nombre"}})
in
    #"Renamed Columns";

shared FechasJornada = let
    Source = Sql.Database(server_datawarehouse, bd_datawarehouse),
    dwh_vFechasJornada = Source{[Schema="dwh",Item="vFechasJornada"]}[Data]
in
    dwh_vFechasJornada;

shared ChannelDateKeys = let
    Source = Sql.Database(server_datawarehouse, bd_datawarehouse),
    dwh_vChannelDateKeys = Source{[Schema="dwh",Item="vChannelDateKeys"]}[Data]
in
    dwh_vChannelDateKeys;

shared #"Partido - Tipo cadena" = let
    Source = Sql.Database(server_datawarehouse, bd_datawarehouse),
    dwh_vMatchChannelType = Source{[Schema="dwh",Item="vMatchChannelType"]}[Data],
    #"Renamed Columns" = Table.RenameColumns(#"dwh_vMatchChannelType",{{"ChannelType_Name", "Tipo cadena"}})
in
    #"Renamed Columns";

shared EmisionPartidos = let
    Source = Sql.Database(server_datawarehouse, bd_datawarehouse),
    dwh_vEmisionPartidos = Source{[Schema="dwh",Item="vEmisionPartidos"]}[Data]
in
    dwh_vEmisionPartidos;

shared #"Cadena min2min" = let
    Source = Sql.Database(server_datawarehouse, bd_datawarehouse),
    dwh_vDimChannel = Source{[Schema="dwh",Item="vDimChannel"]}[Data],
    #"Renamed Columns" = Table.RenameColumns(dwh_vDimChannel,{{"Channel_Id", "Cadena - Id"}, {"Channel_Name", "Cadena"}, {"Channel_Type", "Tipo cadena"}})
in
    #"Renamed Columns";

shared Reports = let
    Source = Table.FromRows(Json.Document(Binary.Decompress(Binary.FromText("xY9BboMwEEWvYllil5pCdt2h9ATZoiwGPApWnRnkMYl6nB6gp8jFalCAlAO0u5n/v/T/q2td6J2u6P7lnThRFlXES88BLCTjHSJPIgzWIbUOxsfDGjIp1cXYy1uee1/YKw6EEsG6gMJDaFFM47kxLQc0N0eWb2IIY774uQXpGoZgJa/mnqx8JWgdE/iXirLDPquKaWIy1vKezqlfn3a1LrccXYoEx7LV/Uh0/wZRn1NmEXsI0VkWo45AH47Oo7GI/8A5Ezxj7tNx4EuaBdFdYaZUrR8alI2Z9v8mRYoBVflI/wXT05yVKF2PBTPZ6Qc=", BinaryEncoding.Base64), Compression.Deflate)), let _t = ((type text) meta [Serialized.Text = true]) in type table [#"Report - Id" = _t, #"Report - Name" = _t, #"Report - Description" = _t, #"Report - ImageURL" = _t, #"Report - Group" = _t]),
    #"Replaced Value" = Table.ReplaceValue(Source,"ll1dveune",DeploymentEnvironment,Replacer.ReplaceValue,{"Report - ImageURL"})
in
    #"Replaced Value";

shared #"Audiencia minuto - Ambito" = let
    Source = Sql.Database(server_datawarehouse, bd_datawarehouse),
    dwh_vFtAudienceMinuteToMinute_Ambito = Source{[Schema="dwh",Item="vFtAudienceMinuteToMinute_Ambito"]}[Data]
in
    dwh_vFtAudienceMinuteToMinute_Ambito;

shared #"Franja Ambito" = let
    Source = Sql.Database(server_datawarehouse, bd_datawarehouse),
    dwh_vDimFranja = Source{[Schema="dwh",Item="vDimFranja"]}[Data]
in
    dwh_vDimFranja;

shared #"Cadena min2min Ambito" = let
    Source = Sql.Database(server_datawarehouse, bd_datawarehouse),
    dwh_vDimChannel = Source{[Schema="dwh",Item="vDimChannel"]}[Data],
    #"Renamed Columns" = Table.RenameColumns(dwh_vDimChannel,{{"Channel_Id", "Cadena - Id"}, {"Channel_Name", "Cadena"}, {"Channel_Type", "Tipo cadena"}})
in
    #"Renamed Columns";

shared #"Ámbito geográfico min2min" = let
    Source = #"Ámbito geográfico"
in
    Source;

shared #"Fecha min2min Ambito" = let
    Source = #"Fecha min2min"
in
    Source;

shared #"Partido min2min" = let
    Source = Partido
in
    Source;