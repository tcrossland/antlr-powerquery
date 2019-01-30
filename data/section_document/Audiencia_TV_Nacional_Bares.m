section Section1;

shared #"Ámbito geográfico" = let
    Source = Sql.Database(server_datawarehouse, bd_datawarehouse),
    dwh_vDimAmbitoGeografico = Source{[Schema="dwh",Item="vDimAmbitoGeografico"]}[Data],
    #"Renamed Columns" = Table.RenameColumns(dwh_vDimAmbitoGeografico,{{"AmbitoGeografico_Id", "Ámbito geográfico - Id"}, {"AmbitoGeografico_Name", "Ámbito geográfico"}})
in
    #"Renamed Columns";

shared Cadena = /* Keep only national channels */

let
    Source = Sql.Database(server_datawarehouse, bd_datawarehouse),
    dwh_vDimChannel = Value.NativeQuery(
            Source,
            "
SELECT Channel_Id, Channel_Name, Channel_Type
FROM dwh.vDimChannel 
WHERE ChannelFlagNational = 1
"
            )
,
    #"Renamed Columns" = Table.RenameColumns(dwh_vDimChannel,{{"Channel_Id", "Cadena - Id"}, {"Channel_Name", "Cadena"}, {"Channel_Type", "Tipo cadena"}})
in
    #"Renamed Columns";

shared Competición = let
    Source = Sql.Database(server_datawarehouse, bd_datawarehouse),
    dwh_vDimCompetition = Source{[Schema="dwh",Item="vDimCompetition"]}[Data],
    #"Renamed Columns" = Table.RenameColumns(dwh_vDimCompetition,{{"Competition_Id", "Competición - Id"}, {"Competition_Name", "Competición"}})
in
    #"Renamed Columns";

shared Equipo = /* Use a query to filter and keep only those teams that have a match in a season after the first season with bares data and in a competition with bares data */

let
    Source = Sql.Database(server_datawarehouse, bd_datawarehouse),
    dwh_vDimTeam = Value.NativeQuery(
            Source, "
SELECT DISTINCT t.* 
FROM dwh.vDimTeam t
  INNER JOIN dwh.vDimMatchTeamRelation m ON t.Team_Id = m.Team_Id1
  INNER JOIN dwh.vAudienceBares_StartSeason s ON m.Season_Id >= s.StartSeason_Id
  INNER JOIN dwh.vAudienceBares_ValidCompetitions c ON m.Competition_Id = c.Competition_Id"
            ),
    #"Renamed Columns" = Table.RenameColumns(dwh_vDimTeam,{{"Team_Id", "Equipo - Id"}, {"Team_Name", "Equipo - Nombre"}, {"Team_ShortName", "Equipo - Abreviatura"}, {"Team_Nickname", "Equipo"}, {"Team_LogoPath", "Equipo - Ruta logo"}, {"Team_MediumName", "Equipo - Nombre corto"}, {"CurrentSegment_Code", "Segmento"}})
in
    #"Renamed Columns"
;

shared #"Equipo 2" = let
    Source = Equipo
in
    Source ;

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

shared #"Fecha partido" = let
    Source = Sql.Database(server_datawarehouse, bd_datawarehouse),
    dwh_vDimDate_Match = Source{[Schema="dwh",Item="vDimDate_Match"]}[Data],
    #"Renamed Columns" = Table.RenameColumns(dwh_vDimDate_Match,{{"DateMatch_Id", "F. partido - Id"}, {"DateMatch_Name", "Fecha partido"}, {"DateMatch_WeekDayName", "Día semana"}, {"DateMatch_MonthOfYear", "F. partido - Mes del año"}, {"DateMatch_Month", "F. partido - Mes"}, {"DateMatch_QuarterOfYear", "F. partido - Trimestre del año"}, {"DateMatch_Quarter", "F. partido - Trimestre"}, {"DateMatch_Year", "F. partido - Año"}, {"DateMatch_WeekDayNum", "F. partido - Num día semana"}, {"DateMatch_MonthNum", "F. partido - Num mes"}, {"DateMatch_WeekDayAbrev", "F. partido - Día sem"}})
in
    #"Renamed Columns";

shared Género = let
    Source = Sql.Database(server_datawarehouse, bd_datawarehouse),
    dwh_vDimGenre = Source{[Schema="dwh",Item="vDimGenre"]}[Data],
    #"Renamed Columns" = Table.RenameColumns(dwh_vDimGenre,{{"Genre_Name", "Género"}})
in
    #"Renamed Columns";

shared #"Grupo días" = let
    Source = Table.FromRows(Json.Document(Binary.Decompress(Binary.FromText("i45WMlTSAeOwYBcfKNNQKVYnWskIyAJh3wgvKMsYLG6MIW4KFjfBEDcHi5tiWmAEljDDlDABS5hjSpgpxcYCAA==", BinaryEncoding.Base64), Compression.Deflate)), let _t = ((type text) meta [Serialized.Text = true]) in type table [DayNumOfWeek = _t, #"Group Id" = _t, #"Group Nom" = _t, #"Group Order" = _t, DayOrderAlt = _t]),
    #"Changed Type" = Table.TransformColumnTypes(Source,{{"DayNumOfWeek", Int64.Type}, {"Group Id", Int64.Type}, {"Group Nom", type text}, {"Group Order", Int64.Type}}),
    #"Renamed Columns" = Table.RenameColumns(#"Changed Type",{{"DayNumOfWeek", "Num día semana"}, {"Group Id", "Id grupo días"}, {"Group Nom", "Grupo días"}, {"Group Order", "Orden grupo días"}})
in
    #"Renamed Columns";

shared #"Hora partido" = let
    Source = Sql.Database(server_datawarehouse, bd_datawarehouse),
    dwh_vDimTime_Match = Source{[Schema="dwh",Item="vDimTime_Match"]}[Data],
    #"Renamed Columns" = Table.RenameColumns(dwh_vDimTime_Match,{{"TimeMatch_Id", "Hora partido - Id"}, {"TimeMatch_Name", "Hora HH:MM"}, {"TimeMatch_Hour", "Hora partido"}, {"TimeMatch_HourRange", "Rango horas"}})
in
    #"Renamed Columns";

shared Jornada = let
    Source = Sql.Database(server_datawarehouse, bd_datawarehouse),
    dwh_vDimMatchday = Source{[Schema="dwh",Item="vDimMatchday"]}[Data],
    #"Renamed Columns" = Table.RenameColumns(dwh_vDimMatchday,{{"Matchday_Number", "Jornada"}, {"Matchday_Name", "Jornada - Nombre"}})
in
    #"Renamed Columns";

shared Medidas = let
    Source = Sql.Database(server_datawarehouse, bd_datawarehouse),
    dwh_Measure = Source{[Schema="dwh",Item="Measure"]}[Data],
    #"Renamed Columns" = Table.RenameColumns(dwh_Measure,{{"Measure_Id", "Medida - Id"}, {"Measure_Name", "Medida"}}),
    #"Merged Queries" = Table.NestedJoin(#"Renamed Columns",{"Medida - Id"},OrdenMedidas,{"Medida - Id"},"OrdenMedidas",JoinKind.LeftOuter),
    #"Expanded OrdenMedidas" = Table.ExpandTableColumn(#"Merged Queries", "OrdenMedidas", {"Order"}, {"OrdenMedidas.Order"}),
    #"Renamed Columns1" = Table.RenameColumns(#"Expanded OrdenMedidas",{{"OrdenMedidas.Order", "Orden"}}),
    #"Filtered Rows" = Table.SelectRows(#"Renamed Columns1", each ([Measure_Type] = "Audiencia bares"))
in
    #"Filtered Rows";

shared Neteado = let
    Source = Sql.Database(server_datawarehouse, bd_datawarehouse),
    dwh_vDimNeteo = Source{[Schema="dwh",Item="vDimNeteo"]}[Data],
    #"Renamed Columns" = Table.RenameColumns(dwh_vDimNeteo,{{"Neteo", "Neteado"}})
in
    #"Renamed Columns";

shared #"Nivel socioeconómico" = let
    Source = Sql.Database(server_datawarehouse, bd_datawarehouse),
    dwh_vDimSocioEconomicLevel = Source{[Schema="dwh",Item="vDimSocioEconomicLevel"]}[Data],
    #"Renamed Columns" = Table.RenameColumns(dwh_vDimSocioEconomicLevel,{{"SocioEconomicLevel_Name", "Nivel socio-económico"}, {"SocioEconomicLevel_Id", "Nivel socio-económico - Id"}})
in
    #"Renamed Columns";

shared Partido = let
    Source = Sql.Database(server_datawarehouse, bd_datawarehouse),
    dwh_vDimMatch = Value.NativeQuery(
            Source, "
                SELECT m.* FROM dwh.vDimMatch  m
                  INNER JOIN dwh.vAudienceBares_StartSeason s ON m.Season_Id >= s.StartSeason_Id
                  INNER JOIN dwh.vAudienceBares_ValidCompetitions c ON m.Competition_Id = c.Competition_Id
                "),
    #"Renamed Columns" = Table.RenameColumns(dwh_vDimMatch,{{"Match_Id", "Partido - Id"}, {"Match_OptaCode", "Partido - OptaCode"}, {"Match_Name", "Partido - Nombre"}, {"Match_Date", "Partido - Fecha"}, {"Match_ShortName", "Partido - Nombre corto"}, {"Match_NickName", "Partido"}, {"HomeTeam_Id", "Equipo local -Id"}, {"VisitorTeam_Id", "Equipo visitante - Id"}, {"Encuentro_Id", "Encuentro - Id"}, {"Match_NickName_Unique", "Partido ordenado"}})
in
    #"Renamed Columns";

shared #"Rango edad" = let
    Source = Sql.Database(server_datawarehouse, bd_datawarehouse),

    dwh_vDimAgeRange = Value.NativeQuery(Source, "
    SELECT AgeRange_Id, AgeRange_Name, ISNULL(AgeRange_From, 
		CASE 
			WHEN CHARINDEX('-', AgeRange_Name) > 0 THEN SUBSTRING(AgeRange_Name, CHARINDEX('-', AgeRange_Name)-2, 2)
			ELSE 
				CASE 
					WHEN CHARINDEX('+', AgeRange_Name) > 0 THEN SUBSTRING(AgeRange_Name, CHARINDEX('+', AgeRange_Name)-2, 2)
					ELSE 0
				END
			END) AgeRange_From
	, AgeRange_To
    FROM dwh.vDimAgeRange_Bares"
),

    #"Renamed Columns" = Table.RenameColumns(dwh_vDimAgeRange,{{"AgeRange_Id", "Rango edad - Id"}, {"AgeRange_Name", "Rango edad"}, {"AgeRange_From", "Rango edad - Desde"}, {"AgeRange_To", "Rango edad - Hasta"}})
in
    #"Renamed Columns";

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

shared #"Relación partido-equipo" = let
    Source = Sql.Database(server_datawarehouse, bd_datawarehouse),
    dwh_vDimMatchTeamRelation = Value.NativeQuery(
            Source,
            "
SELECT m.* 
FROM dwh.vDimMatchTeamRelation m 
  INNER JOIN dwh.vAudienceBares_StartSeason s ON m.Season_Id >= s.StartSeason_Id
  INNER JOIN dwh.vAudienceBares_ValidCompetitions c ON m.Competition_Id = c.Competition_Id

"
            ),
    #"Renamed Columns" = Table.RenameColumns(dwh_vDimMatchTeamRelation,{{"Match_Id", "Partido - Id"}, {"Team_Id1", "Equipo1 - Id"}, {"Segment_Code1", "Segmento1"}, {"Team_Id2", "Equipo2 - Id"}, {"Segment_Code2", "Segmento2"}})
in
    #"Renamed Columns";

shared Temporada = /* Keep only seasons with bares data */

let
    Source = Sql.Database(server_datawarehouse, bd_datawarehouse),
    dwh_vDimSeason = Value.NativeQuery(
            Source,
            "
SELECT t.*
FROM dwh.vDimSeason t 
  INNER JOIN dwh.vAudienceBares_StartSeason s ON t.Season_Id >= s.StartSeason_Id
"
            )
,
    #"Renamed Columns" = Table.RenameColumns(dwh_vDimSeason,{{"Season_Id", "Temporada - Id"}, {"Season_Name", "Temporada"}, {"PreviousSeason_Id", "Temporada ant - Id"}})
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
    dwh_vFtLastUpdate = Value.NativeQuery(
            Source, "
                SELECT 0 Broadcaster_Id, 'KANTAR' Broadcaster_Name, MAX(Sys_dInsert) LastUpdate FROM dwh.TVAudience_Bares
     ")
in
    #"dwh_vFtLastUpdate";

shared Competición_Logo = let
    Source = Table.FromRows(Json.Document(Binary.Decompress(Binary.FromText("rc7dasIwHAXwVwm5tmlTmbjdVYwjUNMSu90UKbENNRDyL0nUvcceyReb+8C9gHeHcy5+p20xxTN8jHEKL2lqLY1Bn5wOUQ3G6wAn3+tADhYOpAevycW4AS6BOB3T+35LE/g46GBGl1plzaiSoFxUbtA+OSY9WPDJIss+njMyuRHvZy3OHw2XqvyGaT6/kxMEE80Zfmw6/8fp08P16rVCteRbJgu05u98x6+fAm3YlgkubhVDm7dmVZWIr5hcy6osujyjy66RhdjVhWSiYV39d/j36P4L", BinaryEncoding.Base64), Compression.Deflate)), let _t = ((type text) meta [Serialized.Text = true]) in type table [#"Competición - Id" = _t, #"Competición - Logo" = _t]),
    #"Changed Type" = Table.TransformColumnTypes(Source,{{"Competición - Id", Int64.Type}, {"Competición - Logo", type text}}),
    #"Renamed Columns" = Table.RenameColumns(#"Changed Type",{{"Competición - Id", "Competición"}})
in
    #"Renamed Columns";

[ Description = "Name of the dwh database server, ie: ll1tseunesqlentities.database.windows.net" ]
shared server_datawarehouse = "ll1preunesqlentities.database.windows.net" meta [IsParameterQuery=true, Type="Text", IsParameterQueryRequired=true];

[ Description = "Name of the dwh database, ie: ll1tseunesdbentities" ]
shared bd_datawarehouse = "ll1preunesdbentities" meta [IsParameterQuery=true, Type="Text", IsParameterQueryRequired=true];

shared #"Partido ordenado medida" = let
    Source = Sql.Database(server_datawarehouse, bd_datawarehouse),
    dwh_vDimMatchOrdered = Source{[Schema="dwh",Item="vDimMatchOrdered_Audience"]}[Data],
    #"Renamed Columns" = Table.RenameColumns(dwh_vDimMatchOrdered,{{"Match_NickName_Unique", "Partido ordenado"}, {"Medida_Id", "Medida - Id"}, {"Match_Id", "Partido - Id"}})
in
    #"Renamed Columns";

[ Description = "First 9 characters of the name of the environment where the reports are being deployed, ie: ll1tseune" ]
shared DeploymentEnvironment = "ll1preune" meta [IsParameterQuery=true, Type="Text", IsParameterQueryRequired=true];

shared #"Tipo cadena" = let
    Source = Sql.Database(server_datawarehouse, bd_datawarehouse),
    dwh_vDimChannelType = Source{[Schema="dwh",Item="vDimChannelType"]}[Data],

    #"Renamed Columns" = Table.RenameColumns(#"dwh_vDimChannelType",{{"ChannelType_Name", "Tipo cadena"}})
in
    #"Renamed Columns";

shared Reports = let
    Source = Table.FromRows(Json.Document(Binary.Decompress(Binary.FromText("xY9BboMwEEWvYllil5pCdt2h9ATZoiwGPApWnRnkMYl6nB6gp8jFalCAlAO0u5n/v/T/q2td6J2u6P7lnThRFlXES88BLCTjHSJPIgzWIbUOxsfDGjIp1cXYy1uee1/YKw6EEsG6gMJDaFFM47kxLQc0N0eWb2IIY774uQXpGoZgJa/mnqx8JWgdE/iXirLDPquKaWIy1vKezqlfn3a1LrccXYoEx7LV/Uh0/wZRn1NmEXsI0VkWo45AH47Oo7GI/8A5Ezxj7tNx4EuaBdFdYaZUrR8alI2Z9v8mRYoBVflI/wXT05yVKF2PBTPZ6Qc=", BinaryEncoding.Base64), Compression.Deflate)), let _t = ((type text) meta [Serialized.Text = true]) in type table [#"Report - Id" = _t, #"Report - Name" = _t, #"Report - Description" = _t, #"Report - ImageURL" = _t, #"Report - Group" = _t]),
    #"Replaced Value" = Table.ReplaceValue(Source,"ll1dveune",DeploymentEnvironment,Replacer.ReplaceValue,{"Report - ImageURL"})
in
    #"Replaced Value";

shared AudienciaBares_Total = let
    Source = Sql.Database(server_datawarehouse, bd_datawarehouse),
    dwh_vFtTVAudienceBares_Total = Source{[Schema="dwh",Item="vFtTVAudienceBares_Total"]}[Data],
    #"Renamed Columns" = Table.RenameColumns(dwh_vFtTVAudienceBares_Total,{{"AudienceBares", "Locales públicos"}, {"AudienceGuests", "Invitados al hogar"}, {"AudienceSecondHome", "2a residencia"}, {"AudienceOtherDevices", "Otros dispositivos"}, {"AudienceMainHome", "Hogar principal"}, {"TotalAudience", "Total audiencia"}})
in
    #"Renamed Columns";

shared AudienciaBares_Género = let
    Source = Sql.Database(server_datawarehouse, bd_datawarehouse),
    dwh_vFtTVAudienceBares_Genre = Source{[Schema="dwh",Item="vFtTVAudienceBares_Genre"]}[Data],
    #"Renamed Columns" = Table.RenameColumns(dwh_vFtTVAudienceBares_Genre,{{"AudienceMainHome", "Hogar principal"}, {"AudienceGuests", "Invitados al hogar"}, {"AudienceBares", "Locales públicos"}, {"AudienceSecondHome", "2a residencia"}, {"AudienceOtherDevices", "Otros dispositivos"}, {"TotalAudience", "Total audiencia"}})
in
    #"Renamed Columns";

shared OrdenMedidas = let
    Source = Table.FromRows(Json.Document(Binary.Decompress(Binary.FromText("Jca5DQAwCAPAXVxThHcZxP5rxJKvul34gyFxxjbrarGhJluqs60GO7j7", BinaryEncoding.Base64), Compression.Deflate)), let _t = ((type text) meta [Serialized.Text = true]) in type table [#"Medida - Id" = _t, Order = _t]),
    #"Changed Type" = Table.TransformColumnTypes(Source,{{"Medida - Id", Int64.Type}, {"Order", Int64.Type}})
in
    #"Changed Type";

shared AudienciaBares_RangoEdad = let
    Source = Sql.Database(server_datawarehouse, bd_datawarehouse),
    dwh_vFtTVAudienceBares_AgeRange = Source{[Schema="dwh",Item="vFtTVAudienceBares_AgeRange"]}[Data],
    #"Renamed Columns" = Table.RenameColumns(dwh_vFtTVAudienceBares_AgeRange,{{"AudienceGuests", "Invitados al hogar"}, {"AudienceMainHome", "Hogar principal"}, {"AudienceOtherDevices", "Otros dispositivos"}, {"AudienceBares", "Locales públicos"}, {"AudienceSecondHome", "2a residencia"}, {"TotalAudience", "Total audiencia"}})
in
    #"Renamed Columns";

shared AudienciaBares_NivelSocioeconómico = let
    Source = Sql.Database(server_datawarehouse, bd_datawarehouse),
    dwh_vFtTVAudienceBares_SocioEconomicLevel = Source{[Schema="dwh",Item="vFtTVAudienceBares_SocioEconomicLevel"]}[Data],
    #"Renamed Columns" = Table.RenameColumns(dwh_vFtTVAudienceBares_SocioEconomicLevel,{{"AudienceBares", "Locales públicos"}, {"AudienceSecondHome", "2a residencia"}, {"AudienceOtherDevices", "Otros dispositivos"}, {"AudienceMainHome", "Hogar principal"}, {"AudienceGuests", "Invitados al hogar"}, {"TotalAudience", "Total audiencia"}})
in
    #"Renamed Columns";

shared Provincia = let
    Source = Sql.Database(server_datawarehouse, bd_datawarehouse),
    dwh_vDimProvince = Source{[Schema="dwh",Item="vDimProvince"]}[Data],
    #"Renamed Columns" = Table.RenameColumns(dwh_vDimProvince,{{"Province_Name", "Provincia"}})
in
    #"Renamed Columns";

shared AudienciaBares_Provincia = let
    Source = Sql.Database(server_datawarehouse, bd_datawarehouse),
    dwh_vFtTVAudienceBares_Province = Source{[Schema="dwh",Item="vFtTVAudienceBares_Province"]}[Data],
    #"Renamed Columns" = Table.RenameColumns(dwh_vFtTVAudienceBares_Province,{{"AudienceMainHome", "Hogar principal"}, {"AudienceGuests", "Invitados al hogar"}, {"AudienceBares", "Locales públicos"}, {"AudienceSecondHome", "2a residencia"}, {"AudienceOtherDevices", "Otros dispositivos"}, {"TotalAudience", "Total audiencia"}})
in
    #"Renamed Columns";

shared Region = let
    Source = Sql.Database(server_datawarehouse, bd_datawarehouse),
    dwh_vDimRegion = Source{[Schema="dwh",Item="vDimRegion"]}[Data],
    #"Renamed Columns" = Table.RenameColumns(dwh_vDimRegion,{{"Region_Name", "Region"}})
in
    #"Renamed Columns";