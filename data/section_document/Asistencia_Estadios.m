section Section1;

shared Competición = let
    Source = Sql.Database(server_datawarehouse, bd_datawarehouse),
    dwh_vDimCompetition = Source{[Schema="dwh",Item="vDimCompetition"]}[Data],
    #"Renamed Columns" = Table.RenameColumns(dwh_vDimCompetition,{{"Competition_Id", "Competición - Id"}, {"Competition_Name", "Competición"}}),
    #"Only LaLiga Santander and LaLiga 1|2|3 competitions" = Table.SelectRows(#"Renamed Columns", each [#"Competición - Id"] = 1 or [#"Competición - Id"] = 2 or [#"Competición - Id"] = -1)
in
    #"Only LaLiga Santander and LaLiga 1|2|3 competitions";

shared #"Fecha partido" = let
    Source = Sql.Database(server_datawarehouse, bd_datawarehouse),
    dwh_vDimDate_Match = Source{[Schema="dwh",Item="vDimDate_Match"]}[Data],
    #"Renamed Columns" = Table.RenameColumns(dwh_vDimDate_Match,{{"DateMatch_Id", "Fecha partido - Id"}, {"DateMatch_Name", "F. partido"}, {"DateMatch_WeekDayName", "Día semana"}, {"DateMatch_MonthOfYear", "F. partido - Mes del año"}, {"DateMatch_Month", "F. partido - Mes"}, {"DateMatch_QuarterOfYear", "F. partido - Trimestre del año"}, {"DateMatch_Quarter", "F. partido - Trimestre"}, {"DateMatch_Year", "F. partido - Año"}, {"DateMatch_MonthNum", "F. Partido - Num mes"}, {"DateMatch_WeekDayNum", "F. Partido - Num día semana"}, {"DateMatch_WeekDayAbrev", "F. Partido - Día sem abrev"}})
in
    #"Renamed Columns";

shared Partido = let
    Source = Sql.Database(server_datawarehouse, bd_datawarehouse),
    dwh_vDimMatch = Source{[Schema="dwh",Item="vDimMatch"]}[Data],
    #"Only LaLiga Santander and LaLiga 1|2|3 competitions" = Table.SelectRows(dwh_vDimMatch, each [Competition_Id] = 1 or [Competition_Id] = 2 or [Competition_Id] = -1),
    #"Renamed Columns" = Table.RenameColumns(#"Only LaLiga Santander and LaLiga 1|2|3 competitions",{{"Match_Id", "Partido - Id"}, {"Match_OptaCode", "Partido - OptaCode"}, {"Match_Name", "Partido - Nombre"}, {"Match_Date", "Partido - Fecha"}, {"Match_ShortName", "Partido - Nombre corto"}, {"Match_NickName", "Partido"}, {"HomeTeam_Id", "Equipo local - Id"}, {"VisitorTeam_Id", "Equipo visitante - Id"}, {"Encuentro_Id", "Encuentro - Id"}, {"Season_Id", "Temporada - Id"}, {"Competition_Id", "Competición - Id"}, {"Matchday_Number", "Jornada - Id"}}),
    #"Filtered Rows1" = Table.SelectRows(#"Renamed Columns", each true),
    #"Renamed Columns1" = Table.RenameColumns(#"Filtered Rows1",{{"Match_NickName_Unique", "Partido ordenado"}})
in
    #"Renamed Columns1";

shared #"Jornada número" = let
    Source = Sql.Database(server_datawarehouse, bd_datawarehouse),
    dwh_vDimMatchday = Source{[Schema="dwh",Item="vDimMatchday"]}[Data],
    #"Renamed Columns" = Table.RenameColumns(dwh_vDimMatchday,{{"Matchday_Number", "Jornada"}, {"Matchday_Name", "Jornada - Nombre"}}),
    #"Sorted Rows" = Table.Sort(#"Renamed Columns",{{"Jornada", Order.Ascending}})
in
    #"Sorted Rows";

shared #"Relación partido-equipo" = let
    Source = Sql.Database(server_datawarehouse, bd_datawarehouse),
    dwh_vDimMatchTeamRelation = Source{[Schema="dwh",Item="vDimMatchTeamRelation"]}[Data],
    #"Renamed Columns" = Table.RenameColumns(dwh_vDimMatchTeamRelation,{{"Match_Id", "Partido - Id"}, {"Team_Id1", "Equipo - Id"}}),
    #"Only LaLiga Santander and LaLiga 1|2|3 competitions" = Table.SelectRows(#"Renamed Columns", each [Competition_id] = 1 or [Competition_id] = 2)
in
    #"Only LaLiga Santander and LaLiga 1|2|3 competitions";

shared Temporada = let
    Source = Sql.Database(server_datawarehouse, bd_datawarehouse),
    dwh_vDimSeason = Source{[Schema="dwh",Item="vDimSeason"]}[Data],
    #"Renamed Columns" = Table.RenameColumns(dwh_vDimSeason,{{"Season_Id", "Temporada - Id"}, {"Season_Name", "Temporada"}, {"PreviousSeason_Id", "Temporada ant - Id"}})
in
    #"Renamed Columns";

shared Equipo = let
    Source = Sql.Database(server_datawarehouse, bd_datawarehouse),
    dwh_vDimTeam = Source{[Schema="dwh",Item="vDimTeam"]}[Data],
    #"Renamed Columns" = Table.RenameColumns(dwh_vDimTeam,{{"Team_Id", "Equipo - Id"}, {"Team_Name", "Equipo - Nombre"}, {"Team_ShortName", "Equipo - Abreviatura"}, {"Team_Nickname", "Equipo"}, {"Team_LogoPath", "Equipo - Ruta logo"}, {"Team_MediumName", "Equipo - Nombre corto"}})
in
    #"Renamed Columns";

shared #"Equipo local" = let
    Source = Sql.Database(server_datawarehouse, bd_datawarehouse),
    dwh_vDimTeam_Home = Source{[Schema="dwh",Item="vDimTeam"]}[Data],
    #"Renamed Columns" = Table.RenameColumns(dwh_vDimTeam_Home,{{"Team_Id", "Equipo local - Id"}, {"Team_Name", "Equipo local - Nombre"}, {"Team_ShortName", "Equipo local - Abreviatura"}, {"Team_Nickname", "Equipo local"}, {"Team_LogoPath", "Equipo local - Ruta logo"}, {"Team_MediumName", "Equipo local - Nombre corto"}})
in
    #"Renamed Columns";

shared #"Equipo visitante" = let
    Source = Sql.Database(server_datawarehouse, bd_datawarehouse),
    dwh_vDimTeam_Visitor = Source{[Schema="dwh",Item="vDimTeam"]}[Data],
    #"Renamed Columns" = Table.RenameColumns(dwh_vDimTeam_Visitor,{{"Team_Id", "Equipo visitante - Id"}, {"Team_Name", "Equipo visitante - Nombre"}, {"Team_ShortName", "Equipo visitante - Abreviatura"}, {"Team_Nickname", "Equipo visitante"}, {"Team_LogoPath", "Equipo visitante - Ruta logo"}, {"Team_MediumName", "Equipo visitante - Nombre corto"}})
in
    #"Renamed Columns";

shared #"Hora partido" = let
    Source = Sql.Database(server_datawarehouse, bd_datawarehouse),
    dwh_vDimTime_Match = Source{[Schema="dwh",Item="vDimTime_Match"]}[Data],
    #"Renamed Columns" = Table.RenameColumns(dwh_vDimTime_Match,{{"TimeMatch_Id", "Hora partido - Id"}, {"TimeMatch_Name", "Hora HH:MM"}, {"TimeMatch_Hour", "Hora partido"}, {"TimeMatch_HourRange", "Rango horas"}})
in
    #"Renamed Columns";

shared Neteado = let
    Source = Sql.Database(server_datawarehouse, bd_datawarehouse),
    dwh_vDimNeteo = Source{[Schema="dwh",Item="vDimNeteo"]}[Data],
    #"Renamed Columns" = Table.RenameColumns(dwh_vDimNeteo,{{"Neteo", "Neteado"}})
in
    #"Renamed Columns";

shared Asistencia = let
    Source = Sql.Database(server_attendance, bd_attendance),
    dbo_vFtStadiumAttendance = Source{[Schema="MSFT",Item="vFtStadiumAttendance"]}[Data],
    #"Renamed Columns" = Table.RenameColumns(dbo_vFtStadiumAttendance,{{"Matchday_Name", "Jornada"}, {"Match_Id", "Partido - Id"}, {"HomeTeam_Id", "Equipo local - Id"}, {"VisitorTeam_Id", "Equipo visitante - Id"}, {"Attendance", "Asi"}, {"Income", "Recaudación"}, {"ClubMemberTickets", "Socios"}, {"Tickets", "Entradas"}, {"Passes", "Pases"}, {"Invitations", "Invitaciones"}, {"Incidencies", "Incidencias"}, {"DateMatch_Id", "Fecha partido - Id"}, {"TimeMatch_Id", "Hora partido - Id"}, {"Competition_Id", "Competición - Id"}, {"Season_Id", "Temporada - Id"}, {"Matchday_Number", "Jornada - Id"}, {"Capacity", "Afo"}}),
    #"Filtered Rows" = Table.SelectRows(#"Renamed Columns", each true)
in
    #"Filtered Rows";

shared Encuentro = let
    Source = Sql.Database(server_datawarehouse, bd_datawarehouse),
    dwh_vDimEncuentro = Source{[Schema="dwh",Item="vDimEncuentro"]}[Data],
    #"Renamed Columns" = Table.RenameColumns(dwh_vDimEncuentro,{{"Encuentro_Nombre", "Encuentro"}, {"Encuentro_NombreCorto", "Encuentro - Nombre alias"}})
in
    #"Renamed Columns";

shared #"Asistencia equivalente" = let
    Source = Sql.Database(server_attendance, bd_attendance),
    dbo_vFtStadiumAttendance_EquivalentSeason = Source{[Schema="MSFT",Item="vFtStadiumAttendance_EquivalentSeason"]}[Data],
    #"Renamed Columns" = Table.RenameColumns(dbo_vFtStadiumAttendance_EquivalentSeason,{{"HomeTeam_Id", "Equipo local - Id"}, {"VisitorTeam_Id", "Equipo visitante - Id"}, {"Match_Id", "Partido - Id"}, {"Matchday_Number", "Jornada - Id"}, {"Season_Id", "Temporada - Id"}, {"Competition_Id", "Competición - Id"}, {"ReferenceType", "Tipo"}, {"RefSeasonMatchday", "Temporada-Jornada equivalente"}, {"RefSeason_Id", "Temporada equivalente"}, {"RefMatchDay_Number", "Jornada equivalente"}, {"RefMatchAttendance", "Asi equivalente"}, {"IsReal", "Real/Estim"}, {"RefMatchCapacity", "Afo equivalente"}})
in
    #"Renamed Columns";

shared Medidas = let
    Source = Table.FromRows(Json.Document(Binary.Decompress(Binary.FromText("i45WMlTSUXIsziwuSc1LzkxUitWJVjICCaXlF+WDecZAnn9yaUFicubhzXlgIXMUPQq5qSkgnbEA", BinaryEncoding.Base64), Compression.Deflate)), let _t = ((type text) meta [Serialized.Text = true]) in type table [#"Medida - Id" = _t, Medida = _t]),
    #"Changed Type" = Table.TransformColumnTypes(Source,{{"Medida - Id", Int64.Type}, {"Medida", type text}})
in
    #"Changed Type";

shared #"Ultima Jornada" = let
    Source = Sql.Database(server_attendance, bd_attendance),
    dbo_vFtStadiumAttendance = Source{[Schema="MSFT",Item="vFtStadiumAttendance"]}[Data],
    #"Asistencia>0" = Table.SelectRows(dbo_vFtStadiumAttendance, each [Attendance] > 0),
    #"Grouped Rows" = Table.Group(#"Asistencia>0", {"Competition_Id", "Season_Id"}, {{"Ult Jornada", each List.Max([Matchday_Number]), type number}}),
    #"Added Custom1" = Table.AddColumn(#"Grouped Rows", "IdSeasonCompetition", each [Season_Id]*1000 + [Competition_Id]),
    #"Renamed Columns" = Table.RenameColumns(#"Added Custom1",{{"Season_Id", "Temporada - Id"}, {"Competition_Id", "Competición - Id"}}),
    #"Renamed Columns1" = Table.RenameColumns(#"Renamed Columns",{{"Ult Jornada", "LastMatchday_Number"}})
in
    #"Renamed Columns1";

shared GrupoDías = let
    Source = Table.FromRows(Json.Document(Binary.Decompress(Binary.FromText("i45WMlTSAeOwYBcfMDNWJ1rJCMgCYd8ILzALJGaMRcwEi5gpNgPNsAmaYwjGAgA=", BinaryEncoding.Base64), Compression.Deflate)), let _t = ((type text) meta [Serialized.Text = true]) in type table [DayNumOfWeek = _t, #"Group Id" = _t, #"Group Nom" = _t, #"Group Order" = _t]),
    #"Changed Type" = Table.TransformColumnTypes(Source,{{"DayNumOfWeek", Int64.Type}, {"Group Id", Int64.Type}, {"Group Nom", type text}, {"Group Order", Int64.Type}}),
    #"Renamed Columns" = Table.RenameColumns(#"Changed Type",{{"DayNumOfWeek", "Num día semana"}, {"Group Id", "Id grupo días"}, {"Group Nom", "Grupo días"}, {"Group Order", "Orden grupo días"}})
in
    #"Renamed Columns";

[ Description = "Name of the attendance database server (on premise), ie: castorsql02" ]
shared server_attendance = "castorsql02" meta [IsParameterQuery=true, Type="Text", IsParameterQueryRequired=true];

[ Description = "Name of the attendance database, ie: STG_LFP" ]
shared bd_attendance = "STG_LFP" meta [IsParameterQuery=true, Type="Text", IsParameterQueryRequired=true];

shared Competición_Logo = let
    Source = Table.FromRows(Json.Document(Binary.Decompress(Binary.FromText("rc1LCoMwEIDhu2RtXgqF9gzeILiIZtBAmAmZUXv8PiieoLsf/sUXgvKqU5tI5Ye1pXhh2BFYYsoNmPa2AJu50GwWamDOjIlONghir/+uSk0ScF7RlljyGjVHlIgJmt70QoWavjn3vDtTcVVTF1T/b3iM4wf2/XCRlThLPuhr++GHTy8=", BinaryEncoding.Base64), Compression.Deflate)), let _t = ((type text) meta [Serialized.Text = true]) in type table [#"Competición - Id" = _t, #"Competición - Logo" = _t]),
    #"Changed Type" = Table.TransformColumnTypes(Source,{{"Competición - Id", Int64.Type}, {"Competición - Logo", type text}}),
    #"Renamed Columns" = Table.RenameColumns(#"Changed Type",{{"Competición - Id", "Competición"}})
in
    #"Renamed Columns";

shared RefTypeOrder = let
    Source = Table.FromRows(Json.Document(Binary.Decompress(Binary.FromText("i45WckwuKU3MUdJRMlSK1YlWci0szSxLzEnNK0kFihkpxcYCAA==", BinaryEncoding.Base64), Compression.Deflate)), let _t = ((type text) meta [Serialized.Text = true]) in type table [RefType = _t, Order = _t]),
    #"Changed Type" = Table.TransformColumnTypes(Source,{{"RefType", type text}, {"Order", Int64.Type}})
in
    #"Changed Type";

[ Description = "Name of the dwh database server, ie: ll1dveunesqlentities.database.windows.net" ]
shared server_datawarehouse = "ll1tseunesqlentities.database.windows.net" meta [IsParameterQuery=true, Type="Text", IsParameterQueryRequired=true];

[ Description = "Name of the dwh database, ie: ll1dveunesdbentities" ]
shared bd_datawarehouse = "ll1tseunesdbentities" meta [IsParameterQuery=true, Type="Text", IsParameterQueryRequired=true];

shared #"Partido ordenado medida" = let
    Source = Sql.Database(server_datawarehouse, bd_datawarehouse),
    dwh_vDimMatchOrdered = Source{[Schema="dwh",Item="vDimMatchOrdered"]}[Data],
    #"Renamed Columns" = Table.RenameColumns(dwh_vDimMatchOrdered,{{"Match_NickName_Unique", "Partido ordenado"}, {"Medida_Id", "Medida - Id"}, {"Match_Id", "Partido - Id"}}),
    #"Filtered Rows" = Table.SelectRows(#"Renamed Columns", each [#"Medida - Id"] <= 3 or [#"Medida - Id"] = 7)
in
    #"Filtered Rows";

shared #"Ult actualización" = let
    Source = Sql.Database(server_attendance, bd_attendance),
    MSFT_vFtLastUpdate = Source{[Schema="MSFT",Item="vFtLastUpdate"]}[Data]
in
    MSFT_vFtLastUpdate;

[ Description = "First 9 characters of the name of the environment where the reports are being deployed, ie: ll1dveune" ]
shared DeploymentEnvironment = "ll1tseune" meta [IsParameterQuery=true, Type="Text", IsParameterQueryRequired=true];

shared #"Ult Jornada Asistencia" = let
    Source = Sql.Database(server_attendance, bd_attendance),
    dbo_vFtStadiumAttendance = Source{[Schema="MSFT",Item="vFtStadiumAttendance"]}[Data],
    #"Asistencia>0" = Table.SelectRows(dbo_vFtStadiumAttendance, each [Attendance] > 0),
    #"Grouped Rows" = Table.Group(#"Asistencia>0", {"Competition_Id", "Season_Id"}, {{"Ult Jornada", each List.Max([Matchday_Number]), type number}}),
    #"Added Custom" = Table.AddColumn(#"Grouped Rows", "Matchday_Id", each [Competition_Id]*10000000 + [Season_Id]*1000 + [Ult Jornada])
in
    #"Added Custom";

shared Jornada = let
    Source = Sql.Database(server_attendance, bd_attendance),
    dbo_vFtStadiumAttendance = Source{[Schema="MSFT",Item="vFtStadiumAttendance"]}[Data],
    #"Grouped Rows" = Table.Group(dbo_vFtStadiumAttendance, {"Season_Id", "Competition_Id", "Matchday_Number"}, {{"Matchday_Name", each List.Max([Matchday_Name]), type text}}),
    #"Sorted Rows" = Table.Sort(#"Grouped Rows",{{"Season_Id", Order.Ascending}, {"Competition_Id", Order.Ascending}, {"Matchday_Number", Order.Ascending}}),
    #"Added Custom" = Table.AddColumn(#"Sorted Rows", "Matchday_Id", each [Competition_Id]*10000000 + [Season_Id]*1000 + [Matchday_Number]),
    #"Merged Queries" = Table.NestedJoin(#"Added Custom",{"Matchday_Id"},#"Ult Jornada Asistencia",{"Matchday_Id"},"Ult Jornada Asistencia",JoinKind.LeftOuter),
    #"Expanded Ult Jornada Asistencia" = Table.ExpandTableColumn(#"Merged Queries", "Ult Jornada Asistencia", {"Ult Jornada"}, {"Ult Jornada Asistencia.Ult Jornada"}),
    #"Added col Jornada" = Table.AddColumn(#"Expanded Ult Jornada Asistencia", "Jornada", each if [Matchday_Number]=[Ult Jornada Asistencia.Ult Jornada] then "Última jornada" else [Matchday_Number]),
    #"Added col Orden Jornada" = Table.AddColumn(#"Added col Jornada", "Orden Jornada", each if [Jornada] = "Última jornada" then "-1" else [Matchday_Number] ),
    #"Added Custom1" = Table.AddColumn(#"Added col Orden Jornada", "JornadaTemporadaAnterior", each [Competition_Id]*10000000 + ([Season_Id]-1)*1000 + [Matchday_Number]),
    #"Added Custom2" = Table.AddColumn(#"Added Custom1", "IdSeasonCompetition", each [Season_Id]*1000 + [Competition_Id])
in
    #"Added Custom2";

shared JornadaInter = let
    Source = Sql.Database(server_attendance, bd_attendance),
    dbo_vFtStadiumAttendance = Source{[Schema="MSFT",Item="vFtStadiumAttendance"]}[Data],
    #"Grouped Rows" = Table.Group(dbo_vFtStadiumAttendance, {"Season_Id", "Competition_Id", "Matchday_Number"}, {{"Matchday_Name", each List.Max([Matchday_Name]), type text}}),
    #"Sorted Rows" = Table.Sort(#"Grouped Rows",{{"Season_Id", Order.Ascending}, {"Competition_Id", Order.Ascending}, {"Matchday_Number", Order.Ascending}}),
    #"Added Custom" = Table.AddColumn(#"Sorted Rows", "Matchday_Id", each [Competition_Id]*10000000 + [Season_Id]*1000 + [Matchday_Number]),
    #"Added Custom1" = Table.AddColumn(#"Added Custom", "IdSeasonCompetition", each [Season_Id]*1000 + [Competition_Id])
in
    #"Added Custom1";