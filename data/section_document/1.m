// "// line with comments /* ho humm */ \""

/*
multi //
*/

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
    #"Filtered Rows" = Table.SelectRows(dwh_Measure, each ([Measure_Type] = "Google analytics")),
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

[ Description = "First 9 characters of the name of the environment where the reports are being deployed, ie: ll1tseune" ]
shared DeploymentEnvironment = "ll1preune" meta [IsParameterQuery=true, Type="Text", IsParameterQueryRequired=true];

[ Description = "Subfloder for FutbolFemenino-WithCountry-Week files. Must begin with a ""/""." ]
shared #"ADLS_FutbolFemenino-WithCountry-Week" = "/digitalaudienceweekly/futbolFemeninoByCountry" meta [IsParameterQuery=true, Type="Text", IsParameterQueryRequired=true];

[ Description = "Subfloder for FutbolFemenino-WithCountry-Month files. Must begin with a ""/""." ]
shared #"ADLS_FutbolFemenino-WithCountry-Month" = "/digitalaudiencemonthly/futbolFemeninoByCountry" meta [IsParameterQuery=true, Type="Text", IsParameterQueryRequired=true];

[ Description = "Subfolder for LaLigaTV-WithCountry-Week files. Must begin with a ""/""." ]
shared #"ADLS_LaLigaTV-WithCountry-Week" = "/digitalaudienceweekly/laligaTVByCountry" meta [IsParameterQuery=true, Type="Text", IsParameterQueryRequired=true];

[ Description = "Subfolder for LaLigaTV-WithCountry-Month files. Must begin with a ""/""." ]
shared #"ADLS_LaLigaTV-WithCountry-Month" = "/digitalaudiencemonthly/laligaTVByCountry" meta [IsParameterQuery=true, Type="Text", IsParameterQueryRequired=true];

shared Fecha = let
    Source = Sql.Database(server_datawarehouse, bd_datawarehouse),

    dwh_vDimDate = Source{[Schema="dwh",Item="vDimDate"]}[Data],
    #"Filtered Rows" = Table.SelectRows(dwh_vDimDate, each [Year_Num] >= 2014 and [Year_Num] <= Date.Year(DateTime.LocalNow()))
in
    #"Filtered Rows";

shared #"GA-ADLS-WebApp-WithCountry-Week" = let

// Tabla con las columnas del fichero
    FicheroMuestra = #"Fichero WebApp muestra con país",

// Ruta raíz en el datalake
    Source = DataLake.Contents(#"ADLS_Root" & #"ADLS_WebApp-WithCountry-Week"),


    #"Removed Columns1" = Table.RemoveColumns(Source,{"Extension", "Date modified", "Date created", "Date accessed", "Attributes"}),
    #"Renamed Columns" = Table.RenameColumns(#"Removed Columns1",{{"Name", "Carpeta años"}, {"Folder Path", "Ruta raíz"}, {"Content", "Contenido raíz"}}),
    #"Expande a meses" = Table.ExpandTableColumn(#"Renamed Columns", "Contenido raíz", {"Content", "Name", "Folder Path"}, {"Content.Content", "Carpeta meses", "Ruta año"}),
    #"Renamed Columns1" = Table.RenameColumns(#"Expande a meses",{{"Content.Content", "Contenido meses"}}),
    #"Expanded Contenido meses" = Table.ExpandTableColumn(#"Renamed Columns1", "Contenido meses", {"Content", "Name", "Folder Path"}, {"Content", "Name", "Folder Path"}),
    #"Renamed Columns2" = Table.RenameColumns(#"Expanded Contenido meses",{{"Name", "Carpeta días"}, {"Folder Path", "Ruta mes"}, {"Content", "Contenido días"}}),
    #"Expanded Contenido días" = Table.ExpandTableColumn(#"Renamed Columns2", "Contenido días", {"Content", "Name", "Extension", "Date modified", "Folder Path"}, {"Content", "Name", "Extension", "Date modified", "Folder Path"}),
    #"Renamed Columns3" = Table.RenameColumns(#"Expanded Contenido días",{{"Folder Path", "Ruta día"}, {"Name", "Fichero"}, {"Content", "Contenido fichero"}}),

// Extracción binaria de los ficheros para pasarlos a tabla. La función especifica el número de columnas
    #"Extrae ficheros de binario a tabla" = Table.AddColumn(#"Renamed Columns3", "Extracción ficheros WebApp", each #"Extrae datos de fichero WebApp con país"([Contenido fichero])),

    #"Removed Other Columns1" = Table.SelectColumns(#"Extrae ficheros de binario a tabla", {"Extracción ficheros WebApp"}),

    #"Expande datos de ficheros" = Table.ExpandTableColumn(#"Removed Other Columns1", "Extracción ficheros WebApp", Table.ColumnNames(FicheroMuestra)),
    #"Changed Type" = Table.TransformColumnTypes(#"Expande datos de ficheros",{{"FromDate", Int64.Type}, {"ToDate", Int64.Type}, {"Users", Int64.Type}, {"newUsers", Int64.Type}, {"Sessions", Int64.Type}, {"avgSessionDuration", type number}}, "en-US"),

// These 2 steps have to be customized in each file type (ie.: Futbol Femenino, LaLigaTV)
#"Added SuborigenId" = Table.AddColumn(#"Changed Type", "Suborigen_Id", each [ViewId] & "-Total"),
#"Added SuborigenName" = Table.AddColumn(#"Added SuborigenId", "Suborigen_Name", each [Source]),

    #"Elimina registros sin fecha" = Table.SelectRows(#"Added SuborigenName", each [ToDate] <> null and [ToDate] <> "")

in
    #"Elimina registros sin fecha";

shared #"GA-ADLS-WebApp-WithCountry-Month" = let

// Tabla con las columnas del fichero
    FicheroMuestra = #"Fichero WebApp muestra con país",

// Ruta raíz en el datalake
    Source = DataLake.Contents(#"ADLS_Root" & #"ADLS_WebApp-WithCountry-Month"),

    #"Removed Columns1" = Table.RemoveColumns(Source,{"Extension", "Date modified", "Date created", "Date accessed", "Attributes"}),
    #"Renamed Columns" = Table.RenameColumns(#"Removed Columns1",{{"Name", "Carpeta años"}, {"Folder Path", "Ruta raíz"}, {"Content", "Contenido raíz"}}),
    #"Expande a meses" = Table.ExpandTableColumn(#"Renamed Columns", "Contenido raíz", {"Content", "Name", "Folder Path"}, {"Content.Content", "Carpeta meses", "Ruta año"}),
    #"Renamed Columns1" = Table.RenameColumns(#"Expande a meses",{{"Content.Content", "Contenido meses"}}),
    #"Expanded Contenido meses" = Table.ExpandTableColumn(#"Renamed Columns1", "Contenido meses", {"Content", "Name", "Folder Path"}, {"Content", "Name", "Folder Path"}),
    #"Renamed Columns2" = Table.RenameColumns(#"Expanded Contenido meses",{{"Name", "Fichero"}, {"Folder Path", "Ruta mes"}, {"Content", "Contenido fichero"}}),

    // 
    #"Extrae ficheros de binario a tabla" = Table.AddColumn(#"Renamed Columns2", "Extracción ficheros WebApp", each #"Extrae datos de fichero WebApp con país"([Contenido fichero])),

    #"Removed Other Columns1" = Table.SelectColumns(#"Extrae ficheros de binario a tabla", {"Extracción ficheros WebApp"}),

    #"Expande datos de ficheros" = Table.ExpandTableColumn(#"Removed Other Columns1", "Extracción ficheros WebApp", Table.ColumnNames(FicheroMuestra)),

    #"Changed Type" = Table.TransformColumnTypes(#"Expande datos de ficheros",{{"FromDate", Int64.Type}, {"ToDate", Int64.Type}, {"Users", Int64.Type}, {"newUsers", Int64.Type}, {"Sessions", Int64.Type}, {"avgSessionDuration", type number}}, "en-US"),

// These 2 steps have to be customized in each file type (ie.: Futbol Femenino, LaLigaTV)
#"Added SuborigenId" = Table.AddColumn(#"Changed Type", "Suborigen_Id", each [ViewId] & "-Total"),
#"Added SuborigenName" = Table.AddColumn(#"Added SuborigenId", "Suborigen_Name", each [Source]),

    #"Elimina registros sin fecha" = Table.SelectRows(#"Added SuborigenName", each [ToDate] <> null and [ToDate] <> "")

in
    #"Elimina registros sin fecha";

shared #"GA-Suborigen" = // In all sources, we get the different Suborigenes

let
// COMENTADO HASTA QUE TENGAMOS DATOS
//    FutbolFemenino = #"GA-ADLS-FútbolFemenino-WithCountry-Week",
//    #"Grouped Rows FútbolFemenino" = Table.Group(FutbolFemenino, {"ViewId"}, {{"Suborigen_Name", each List.Max([Suborigen]), type text}}),

    WebApp = #"GA-ADLS-WebApp-WithoutCountry-Week",
    #"Grouped Rows WebApp" = Table.Group(WebApp , {"Suborigen_Id"}, {{"Suborigen_Name", each List.Max([Suborigen_Name]), type text}}),

//    LaLigaTV = #"GA-ADLS-LaLigaTV-WithCountry-Week",
//    #"Grouped Rows LaLigaTV" = Table.Group(LaLigaTV, {"ViewId"}, {{"Suborigen_Name", each List.Max([Suborigen]), type text}}),


//    #"Appended Query" = Table.Combine({#"Grouped Rows FútbolFemenino", #"Grouped Rows WebApp", #"Grouped Rows LaLigaTV"}),
    #"Appended Query" = Table.Combine({#"Grouped Rows WebApp"}),

    #"Grouped Rows fin" = Table.Group(#"Appended Query", {"Suborigen_Id"}, {{"Suborigen_Name", each List.Max([Suborigen_Name]), type text}})
in
    #"Grouped Rows fin";

shared ReportsDefinition = let
    Source = Table.FromRows(Json.Document(Binary.Decompress(Binary.FromText("rVbLctowFP0VD9smHsl6WFo6mdDHkJbilLSTyTDCKFRTYzO2SUv+qMtOd93yY5WxA7ZjgZN2AVzgnnN0r+9DNzc9b7lMeyc9BpALIXW0eRVnItSfUL/0v8W79eFOBUqE1kAM1Fz0bk/2UI4AdiAyQgfC+rhSkZJhA0coRJAewOVS1tW4jmLQ5YdQOebsbOxVURxyAFxGjKixSrKVDs9LZFQ7JSeOCzAERuQbKWaWHweBTGo4CohDmGvE+QuRZI3gOEWuCyg/HJyfiSytwiBwHAYwMIe3xfVFlIl0bV2KJKjFCBEngFB0BD9cPTyEcgs8D1dTWUhjBHVmm4VzLafFuzVM4rUMstjKMcWx+6tsGod9uZCRimLt51IKHb49f3/zp/EnqNFdpEux+SWsU6v0tHaurdSVwm6nflrinan3BXyMelfKJXl4nJ1joksI4A45+eR7nQ+d00LYKdWXm58/VBCbqIuYsL+Mk2xbCpARjimAxlKoI/YcuglqNVD51fTwdy4NlmcOldHI9/NMiEBO4/jbTrsSlX6N5EymeY/r6thW/aP/6dOITIxl8116o3OvI20N0s59V5oTnZhIpV8ny0QtZCImM3WvUhVHHaWq9G+jNBPzRCy6ZmMHMKejyqke7WcfuilUVfBVJKxrqaZ5Haf6y/fcNkpMIKaYMsowthEyCe5J/4uiyxjVawjYoLtiPjWrqlffVZbpVdPx2ZTu5iez5yvLrQz0CF/duZUvK6xDCSEOI64Luc14twAu3r9Yi1GkpxOHNjQmv67lJcKQ+WNq3fi33MVsq8y+9slZDr4KpLIe2iF6KTTcy7Hf7l4O+wpEuyOHwwMSermsEmF5+d7c/I6qWH0fodAlzetPcxe03Em+xJp1KrXb3loX1rGEP4FWM93G29ZCJpLDQz6IF1MVydlz5u3j7Ytih2AXmK+Y3iy/lYbryPo8qOq/juN5KF9pa761luEqPdACBDA97hym283YAgXlUBO1TLzn9BtxHDe/AiObsm790B95LxdDiFAMic1hN7GzfxHTV2UGMbIJ6Sb2blgbW+O8YO7NO1tLQBcBzjC0sUlhvC+l278=", BinaryEncoding.Base64), Compression.Deflate)), let _t = ((type text) meta [Serialized.Text = true]) in type table [Report_Id = _t, ViewId = _t, Segment = _t, #"Flag count to global" = _t, #"Grupo audiencia" = _t, Suborigen_Name = _t]),
    #"Added Custom" = Table.AddColumn(Source, "Suborigen_Id", each [ViewId] & "-" & [Segment])
in
    #"Added Custom";

shared #"GA-CombinedData-WithCountry-Week" = let
// Aquí combinaremos los datos de LaLigaTV y FutbolFemenino cuando se tengan
    Source = Table.Combine({#"GA-ADLS-WebApp-WithCountry-Week"}),


// CUANDO SE TENGA LaLigaTV    #"Changed Type" = Table.TransformColumnTypes(Source,{{"TotalEvents", Int64.Type}}),

    #"Merged Queries" = Table.NestedJoin(Source, {"ToDate"},Fecha,{"Date_Id"},"Fecha",JoinKind.LeftOuter),
    #"Expanded Fecha" = Table.ExpandTableColumn(#"Merged Queries", "Fecha", {"Season_Id", "Week_Number", "Week_Id"}, {"Season_Id", "Week_Number", "Week_Id"})
in
    #"Expanded Fecha";

[ Description = "Subfolder for WebApp-WithCountry-Week files. Must begin with a ""/""." ]
shared #"ADLS_WebApp-WithCountry-Week" = "/digitalaudienceweekly/usersSessionsByCountry" meta [IsParameterQuery=true, Type="Text", IsParameterQueryRequired=true];

shared GetSubfolder = let
    Source = (#"Root", #"Folder") => 
        let
            Source = DataLake.Contents(Root & Folder)
        in
            Source
in
    Source;

shared Reports = let
    Source = Table.FromRows(Json.Document(Binary.Decompress(Binary.FromText("vZFNTsMwEIWvEkViVxJayo/YlUph0wVKCghFWcTOKDWYmSh2iHo1tlyMsYvS9ACpZDnzXmy9T895Hr6BCGduDzblRtUli521jXmIY63n1Td0CMaWlWrBUNdKMJHQJCJJLUS9wop6EyHYePjPU0OtrcCoGuMnolrDCku9t0qamJMuH0lXUYM1Z92HxSwPD9HbVzZG46QcL/iJ1OPF4kpJ+odZephV0xgW7nOmTlzUuJS7USnLzF00QzNHPSnSSdiY7cazJZ0VpBP4AlRIbCe/P84JRtbZn+/ao611J8D189zSHqSlYHAmJeK4D45zYSeF3XqqNM0yFinw7cCQVKX2SLwW/sA7dZYxWfO0PUy85mFR/AE=", BinaryEncoding.Base64), Compression.Deflate)), let _t = ((type text) meta [Serialized.Text = true]) in type table [Report_Id = _t, Report_Name = _t, Report_Logo = _t, Report_Order = _t]),
    #"Sorted Rows" = Table.Sort(Source,{{"Report_Order", Order.Ascending}}),
    #"Changed Type1" = Table.TransformColumnTypes(#"Sorted Rows",{{"Report_Order", Int64.Type}}),
    #"Changed Type" = Table.TransformColumnTypes(#"Changed Type1",{{"Report_Name", type text}, {"Report_Logo", type text}, {"Report_Order", Int64.Type}}),

    #"Replaced Value" = Table.ReplaceValue(#"Changed Type","ll1dveune",DeploymentEnvironment,Replacer.ReplaceText,{"Report_Logo"})

in
    #"Replaced Value";

shared #"LaLigaFollowersByCountry-Week" = let
    Source = Sql.Database(server_datawarehouse, bd_datawarehouse),

    dwh_LaLigaFollowers = Source{[Schema="dwh",Item="vFtFollowersByCountry_Week"]}[Data],
    #"Filtered Rows" = Table.SelectRows(dwh_LaLigaFollowers, each ([Entity_Code] = "LaLiga Santander")),
    #"Removed Columns" = Table.RemoveColumns(#"Filtered Rows",{"Sem_dIni", "Sem_dFin", "Entity_Code"}),
    #"Renamed Columns" = Table.RenameColumns(#"Removed Columns",{{"ISO2", "CountryIsoCode"}, {"SemFechaIni_Id", "FromDate"}, {"SemFechaFin_Id", "ToDate"}}),
    #"Added Custom" = Table.AddColumn(#"Renamed Columns", "Custom", each [Source] & "-" & [ViewId]),
    #"Duplicated Column" = Table.DuplicateColumn(#"Added Custom", "Custom", "Custom - Copy"),
    #"Duplicated Column1" = Table.DuplicateColumn(#"Duplicated Column", "Custom", "Custom - Copy.1"),
    #"Removed Columns1" = Table.RemoveColumns(#"Duplicated Column1",{"ViewId"}),
    #"Renamed Columns1" = Table.RenameColumns(#"Removed Columns1",{{"Custom", "ViewId"}, {"Custom - Copy", "Suborigen_Id"}, {"Custom - Copy.1", "Suborigen_Name"}})
in
    #"Renamed Columns1";

shared #"GA+SN WithCountry-Week" = let
    Source = Table.Combine({#"GA-CombinedData-WithCountry-Week", #"LaLigaFollowersByCountry-Week"})
in
    #"Source";

shared #"SN-Suborigen" = let
    SocialNetworks_WithCountry = #"LaLigaFollowersByCountry-Week",
    #"Grouped Rows SocialNetworks 1" = Table.Group(SocialNetworks_WithCountry, {"Suborigen_Id"}, {{"Suborigen_Name", each List.Max([Suborigen_Name]), type text}}),

    SocialNetworks_WithoutCountry = #"SN-LaLigaFollowers-Week",
    #"Grouped Rows SocialNetworks 2" = Table.Group(SocialNetworks_WithoutCountry, {"Suborigen_Id"}, {{"Suborigen_Name", each List.Max([Suborigen_Name]), type text}}),


    Combine = Table.Combine({#"Grouped Rows SocialNetworks 1", #"Grouped Rows SocialNetworks 2"}),

    Source = Table.Group(Combine, {"Suborigen_Id"}, {{"Suborigen_Name", each List.Max([Suborigen_Name]), type text}})

in
    Source;

shared Suborigen = let
    Source = Table.Combine({#"GA-Suborigen", #"SN-Suborigen"})
in
    Source;

[ Description = "Subfolder for WebApp-WithCountry-Month files. Must begin with a ""/""." ]
shared #"ADLS_WebApp-WithCountry-Month" = "/digitalaudiencemonthly/usersSessionsByCountry" meta [IsParameterQuery=true, Type="Text", IsParameterQueryRequired=true];

shared #"LaLigaFollowersByCountry-Month" = let
    Source = Sql.Database(server_datawarehouse, bd_datawarehouse),

    dwh_LaLigaFollowers = Source{[Schema="dwh",Item="vFtFollowersByCountry_Month"]}[Data],

    #"Filtered Rows" = Table.SelectRows(dwh_LaLigaFollowers, each ([Entity_Code] = "LaLiga Santander")),

    #"Removed Columns" = Table.RemoveColumns(#"Filtered Rows",{"Month_BeginDate", "Month_EndDate", "Entity_Code", "LastDateWithData"}),

    #"Renamed Columns" = Table.RenameColumns(#"Removed Columns",{{"ISO2", "CountryIsoCode"}, {"MonthBeginDate_Id", "FromDate"}, {"MonthEndDate_Id", "ToDate"}}),
    #"Added Custom" = Table.AddColumn(#"Renamed Columns", "Custom", each [Source] & "-" & [ViewId]),
    #"Duplicated Column" = Table.DuplicateColumn(#"Added Custom", "Custom", "Custom - Copy"),
    #"Duplicated Column1" = Table.DuplicateColumn(#"Duplicated Column", "Custom", "Custom - Copy.1"),
    #"Removed Columns1" = Table.RemoveColumns(#"Duplicated Column1",{"ViewId"}),
    #"Renamed Columns1" = Table.RenameColumns(#"Removed Columns1",{{"Custom", "ViewId"}, {"Custom - Copy", "Suborigen_Id"}, {"Custom - Copy.1", "Suborigen_Name"}})
in
    #"Renamed Columns1";

shared #"GA-CombinedData-WithCountry-Month" = let
// Aquí combinaremos los datos de LaLigaTV y FutbolFemenino cuando se tengan
    Source = Table.Combine({#"GA-ADLS-WebApp-WithCountry-Month"}),


// CUANDO SE TENGA LaLigaTV    #"Changed Type" = Table.TransformColumnTypes(Source,{{"TotalEvents", Int64.Type}}),

    #"Merged Queries" = Table.NestedJoin(Source, {"ToDate"},Fecha,{"Date_Id"},"Fecha",JoinKind.LeftOuter),
    #"Expanded Fecha" = Table.ExpandTableColumn(#"Merged Queries", "Fecha", {"Month_Num", "Month_YYYYMM", "Year_Num"}, {"Month_Num", "Month_YYYYMM", "Year_Num"}),
    #"Renamed Columns" = Table.RenameColumns(#"Expanded Fecha",{{"Month_YYYYMM", "Month_Id"}})
in
    #"Renamed Columns";

shared #"GA+SN WithCountry-Month" = let
    Source = Table.Combine({#"GA-CombinedData-WithCountry-Month", #"LaLigaFollowersByCountry-Month"})
in
    Source;

[ Description = "Subfolder for WebApp-WithCountry-Season files. Must begin with a ""/""." ]
shared #"ADLS_WebApp-WithCountry-Season" = "/digitalaudienceseasonly/usersSessionsByCountry" meta [IsParameterQuery=true, Type="Text", IsParameterQueryRequired=true];

shared #"GA-ADLS-WebApp-WithCountry-Season" = let

// Tabla con las columnas del fichero
    FicheroMuestra = #"Fichero WebApp muestra con país",

// Ruta raíz en el datalake
    Source = DataLake.Contents(#"ADLS_Root" & #"ADLS_WebApp-WithCountry-Season"),


    #"Removed Columns1" = Table.RemoveColumns(Source,{"Extension", "Date modified", "Date created", "Date accessed", "Attributes"}),
    #"Renamed Columns" = Table.RenameColumns(#"Removed Columns1",{{"Name", "Carpeta años"}, {"Folder Path", "Ruta raíz"}, {"Content", "Contenido raíz"}}),
    #"Expande a meses" = Table.ExpandTableColumn(#"Renamed Columns", "Contenido raíz", {"Content", "Name", "Folder Path"}, {"Content.Content", "Carpeta meses", "Ruta año"}),
    #"Renamed Columns1" = Table.RenameColumns(#"Expande a meses",{{"Content.Content", "Contenido meses"}}),
    #"Expanded Contenido meses" = Table.ExpandTableColumn(#"Renamed Columns1", "Contenido meses", {"Content", "Name", "Folder Path"}, {"Content", "Name", "Folder Path"}),
    #"Renamed Columns2" = Table.RenameColumns(#"Expanded Contenido meses",{{"Name", "Carpeta días"}, {"Folder Path", "Ruta mes"}, {"Content", "Contenido días"}}),
    #"Expanded Contenido días" = Table.ExpandTableColumn(#"Renamed Columns2", "Contenido días", {"Content", "Name", "Extension", "Date modified", "Folder Path"}, {"Content", "Name", "Extension", "Date modified", "Folder Path"}),
    #"Renamed Columns3" = Table.RenameColumns(#"Expanded Contenido días",{{"Folder Path", "Ruta día"}, {"Name", "Fichero"}, {"Content", "Contenido fichero"}}),

// Extracción binaria de los ficheros para pasarlos a tabla. La función especifica el número de columnas
    #"Extrae ficheros de binario a tabla" = Table.AddColumn(#"Renamed Columns3", "Extracción ficheros WebApp", each #"Extrae datos de fichero WebApp con país"([Contenido fichero])),

    #"Removed Other Columns1" = Table.SelectColumns(#"Extrae ficheros de binario a tabla", {"Extracción ficheros WebApp"}),

    #"Expande datos de ficheros" = Table.ExpandTableColumn(#"Removed Other Columns1", "Extracción ficheros WebApp", Table.ColumnNames(FicheroMuestra)),
    #"Changed Type" = Table.TransformColumnTypes(#"Expande datos de ficheros",{{"FromDate", Int64.Type}, {"ToDate", Int64.Type}, {"Users", Int64.Type}, {"newUsers", Int64.Type}, {"Sessions", Int64.Type}, {"avgSessionDuration", type number}}, "en-US"),

// These 2 steps have to be customized in each file type (ie.: Futbol Femenino, LaLigaTV)
#"Added SuborigenId" = Table.AddColumn(#"Changed Type", "Suborigen_Id", each [ViewId] & "-Total"),
#"Added SuborigenName" = Table.AddColumn(#"Added SuborigenId", "Suborigen_Name", each [Source]),

    #"Elimina registros sin fecha" = Table.SelectRows(#"Added SuborigenName", each [ToDate] <> null and [ToDate] <> "")

in
    #"Elimina registros sin fecha";

shared #"GA-ADLS-WebApp-WithoutCountry-Week" = let

// Tabla con las columnas del fichero
    FicheroMuestra = #"Fichero WebApp muestra sin país",

// Ruta raíz en el datalake
    Source = DataLake.Contents(#"ADLS_Root" & #"ADLS_WebApp-WithoutCountry-Week"),


    #"Removed Columns1" = Table.RemoveColumns(Source,{"Extension", "Date modified", "Date created", "Date accessed", "Attributes"}),
    #"Renamed Columns" = Table.RenameColumns(#"Removed Columns1",{{"Name", "Carpeta años"}, {"Folder Path", "Ruta raíz"}, {"Content", "Contenido raíz"}}),
    #"Expande a meses" = Table.ExpandTableColumn(#"Renamed Columns", "Contenido raíz", {"Content", "Name", "Folder Path"}, {"Content.Content", "Carpeta meses", "Ruta año"}),
    #"Renamed Columns1" = Table.RenameColumns(#"Expande a meses",{{"Content.Content", "Contenido meses"}}),
    #"Expanded Contenido meses" = Table.ExpandTableColumn(#"Renamed Columns1", "Contenido meses", {"Content", "Name", "Folder Path"}, {"Content", "Name", "Folder Path"}),
    #"Renamed Columns2" = Table.RenameColumns(#"Expanded Contenido meses",{{"Name", "Carpeta días"}, {"Folder Path", "Ruta mes"}, {"Content", "Contenido días"}}),
    #"Expanded Contenido días" = Table.ExpandTableColumn(#"Renamed Columns2", "Contenido días", {"Content", "Name", "Extension", "Date modified", "Folder Path"}, {"Content", "Name", "Extension", "Date modified", "Folder Path"}),
    #"Renamed Columns3" = Table.RenameColumns(#"Expanded Contenido días",{{"Folder Path", "Ruta día"}, {"Name", "Fichero"}, {"Content", "Contenido fichero"}}),

// Extracción binaria de los ficheros para pasarlos a tabla. La función especifica el número de columnas
    #"Extrae ficheros de binario a tabla" = Table.AddColumn(#"Renamed Columns3", "Extracción ficheros WebApp", each #"Extrae datos de fichero WebApp sin país"([Contenido fichero])),

    #"Removed Other Columns1" = Table.SelectColumns(#"Extrae ficheros de binario a tabla",{"Date modified", "Extracción ficheros WebApp"}),

    #"Expande datos de ficheros" = Table.ExpandTableColumn(#"Removed Other Columns1", "Extracción ficheros WebApp", Table.ColumnNames(FicheroMuestra)),
    #"Changed Type" = Table.TransformColumnTypes(#"Expande datos de ficheros",{{"FromDate", Int64.Type}, {"ToDate", Int64.Type}, {"Users", Int64.Type}, {"newUsers", Int64.Type}, {"Sessions", Int64.Type}, {"avgSessionDuration", type number}}, "en-US"),

// These 2 steps have to be customized in each file type (ie.: Futbol Femenino, LaLigaTV)
#"Added SuborigenId" = Table.AddColumn(#"Changed Type", "Suborigen_Id", each [ViewId] & "-Total"),
#"Added SuborigenName" = Table.AddColumn(#"Added SuborigenId", "Suborigen_Name", each [Source]),

    #"Elimina registros sin fecha" = Table.SelectRows(#"Added SuborigenName", each [ToDate] <> null and [ToDate] <> "")

in
    #"Elimina registros sin fecha";

[ Description = "Los datos mensuales no tienen carpetas a nivel de día" ]
shared #"GA-ADLS-WebApp-WithoutCountry-Month" = let

// Tabla con las columnas del fichero
    FicheroMuestra = #"Fichero WebApp muestra sin país",

// Ruta raíz en el datalake
    Source = DataLake.Contents(#"ADLS_Root" & #"ADLS_WebApp-WithoutCountry-Month"),

    #"Removed Columns1" = Table.RemoveColumns(Source,{"Extension", "Date modified", "Date created", "Date accessed", "Attributes"}),
    #"Renamed Columns" = Table.RenameColumns(#"Removed Columns1",{{"Name", "Carpeta años"}, {"Folder Path", "Ruta raíz"}, {"Content", "Contenido raíz"}}),
    #"Expande a meses" = Table.ExpandTableColumn(#"Renamed Columns", "Contenido raíz", {"Content", "Name", "Folder Path"}, {"Content.Content", "Carpeta meses", "Ruta año"}),
    #"Renamed Columns1" = Table.RenameColumns(#"Expande a meses",{{"Content.Content", "Contenido meses"}}),
    #"Expanded Contenido meses" = Table.ExpandTableColumn(#"Renamed Columns1", "Contenido meses", {"Content", "Name", "Folder Path"}, {"Content", "Name", "Folder Path"}),
    #"Renamed Columns2" = Table.RenameColumns(#"Expanded Contenido meses",{{"Name", "Fichero"}, {"Folder Path", "Ruta mes"}, {"Content", "Contenido fichero"}}),
    // 
    #"Extrae ficheros de binario a tabla" = Table.AddColumn(#"Renamed Columns2", "Extracción ficheros WebApp", each #"Extrae datos de fichero WebApp sin país"([Contenido fichero])),

    #"Removed Other Columns1" = Table.SelectColumns(#"Extrae ficheros de binario a tabla", {"Extracción ficheros WebApp"}),

    #"Expande datos de ficheros" = Table.ExpandTableColumn(#"Removed Other Columns1", "Extracción ficheros WebApp", Table.ColumnNames(FicheroMuestra)),

    #"Changed Type" = Table.TransformColumnTypes(#"Expande datos de ficheros",{{"FromDate", Int64.Type}, {"ToDate", Int64.Type}, {"Users", Int64.Type}, {"newUsers", Int64.Type}, {"Sessions", Int64.Type}, {"avgSessionDuration", type number}}, "en-US"),

// These 2 steps have to be customized in each file type (ie.: Futbol Femenino, LaLigaTV)
#"Added SuborigenId" = Table.AddColumn(#"Changed Type", "Suborigen_Id", each [ViewId] & "-Total"),
#"Added SuborigenName" = Table.AddColumn(#"Added SuborigenId", "Suborigen_Name", each [Source]),

    #"Elimina registros sin fecha" = Table.SelectRows(#"Added SuborigenName", each [ToDate] <> null and [ToDate] <> "")

in
    #"Elimina registros sin fecha";

shared #"GA-CombinedData-WithCountry-Season" = let
// Aquí combinaremos los datos de LaLigaTV y FutbolFemenino cuando se tengan
    Source = Table.Combine({#"GA-ADLS-WebApp-WithCountry-Season"}),

// CUANDO SE TENGA LaLigaTV    #"Changed Type" = Table.TransformColumnTypes(Source,{{"TotalEvents", Int64.Type}}),

    #"Merged Queries" = Table.NestedJoin(Source, {"ToDate"},Fecha,{"Date_Id"},"Fecha",JoinKind.LeftOuter),
    #"Expanded Fecha" = Table.ExpandTableColumn(#"Merged Queries", "Fecha", {"Season_Id", "Week_Number", "Week_Id"}, {"Season_Id", "Week_Number", "Week_Id"})
in
    #"Expanded Fecha";

[ Description = "Subfolder for LaLigaTV-WithCountry-Season files. Must begin with a ""/""." ]
shared #"ADLS_LaLigaTV-WithCountry-Season" = "/digitalaudienceseasonly/laligaTVByCountry" meta [IsParameterQuery=true, Type="Text", IsParameterQueryRequired=true];

shared #"GA+SN WithCountry-Season" = let
    Source = Table.Combine({#"GA-CombinedData-WithCountry-Season", #"LaLigaFollowersByCountry-Week"})
in
    Source;

[ Description = "Subfolder for FutbolFemenino-WithCountry-Season files. Must begin with a ""/""." ]
shared #"ADLS_FutbolFemenino-WithCountry-Season" = "/digitalaudienceseasonly/futbolFemeninoByCountry" meta [IsParameterQuery=true, Type="Text", IsParameterQueryRequired=true];

[ Description = "Subfolder for WebApp-WithoutCountry-Week files. Must begin with a ""/""." ]
shared #"ADLS_WebApp-WithoutCountry-Week" = "/digitalaudienceweekly/usersSessions" meta [IsParameterQuery=true, Type="Text", IsParameterQueryRequired=true];

[ Description = "Subfolder for WebApp-WithoutCountry-Month files. Must begin with a ""/""." ]
shared #"ADLS_WebApp-WithoutCountry-Month" = "/digitalaudiencemonthly/usersSessions" meta [IsParameterQuery=true, Type="Text", IsParameterQueryRequired=true];

[ Description = "Subfolder for WebApp-WithoutCountry-Season files. Must begin with a ""/""." ]
shared #"ADLS_WebApp-WithoutCountry-Season" = "/digitalaudienceseasonly/usersSessions" meta [IsParameterQuery=true, Type="Text", IsParameterQueryRequired=true];

shared #"Fichero WebApp muestra sin país" = let
    Source = Table.FromRecords(  
  
{  
    [FromDate = 20171211, ToDate = 20171217, ViewId = "76612905", Source = "Web España"
    , Users = 268, newUsers = 154, Sessions = 466, avgSessionDuration = 243.87982832618025 ]
}  
  
)
in
    Source;

[ Description = "For internal use. Keep it empty." ]
shared #"Parámetro fichero WebApp muestra" = #"Fichero WebApp muestra sin país" meta [IsParameterQuery=true, BinaryIdentifier=#"Fichero WebApp muestra sin país", Type="Binary", IsParameterQueryRequired=true];

shared #"Extrae datos de fichero WebApp sin país" = let
    Source = (#"Parámetro fichero WebApp muestra" as binary) => let
        Source = Csv.Document(#"Parámetro fichero WebApp muestra",[Delimiter="	", Columns=8, Encoding=65001, QuoteStyle=QuoteStyle.None]),
        #"Promoted Headers" = Table.PromoteHeaders(Source, [PromoteAllScalars=true])
    in
        #"Promoted Headers"
in
    Source;

shared #"GA-ADLS-WebApp-WithoutCountry-Season" = let

// Tabla con las columnas del fichero
    FicheroMuestra = #"Fichero WebApp muestra sin país",

// Ruta raíz en el datalake
    Source = DataLake.Contents(#"ADLS_Root" & #"ADLS_WebApp-WithoutCountry-Season"),


    #"Removed Columns1" = Table.RemoveColumns(Source,{"Extension", "Date modified", "Date created", "Date accessed", "Attributes"}),
    #"Renamed Columns" = Table.RenameColumns(#"Removed Columns1",{{"Name", "Carpeta años"}, {"Folder Path", "Ruta raíz"}, {"Content", "Contenido raíz"}}),
    #"Expande a meses" = Table.ExpandTableColumn(#"Renamed Columns", "Contenido raíz", {"Content", "Name", "Folder Path"}, {"Content.Content", "Carpeta meses", "Ruta año"}),
    #"Renamed Columns1" = Table.RenameColumns(#"Expande a meses",{{"Content.Content", "Contenido meses"}}),
    #"Expanded Contenido meses" = Table.ExpandTableColumn(#"Renamed Columns1", "Contenido meses", {"Content", "Name", "Folder Path"}, {"Content", "Name", "Folder Path"}),
    #"Renamed Columns2" = Table.RenameColumns(#"Expanded Contenido meses",{{"Name", "Carpeta días"}, {"Folder Path", "Ruta mes"}, {"Content", "Contenido días"}}),
    #"Expanded Contenido días" = Table.ExpandTableColumn(#"Renamed Columns2", "Contenido días", {"Content", "Name", "Extension", "Date modified", "Folder Path"}, {"Content", "Name", "Extension", "Date modified", "Folder Path"}),
    #"Renamed Columns3" = Table.RenameColumns(#"Expanded Contenido días",{{"Folder Path", "Ruta día"}, {"Name", "Fichero"}, {"Content", "Contenido fichero"}}),

// Extracción binaria de los ficheros para pasarlos a tabla. La función especifica el número de columnas
    #"Extrae ficheros de binario a tabla" = Table.AddColumn(#"Renamed Columns3", "Extracción ficheros WebApp", each #"Extrae datos de fichero WebApp sin país"([Contenido fichero])),

    #"Removed Other Columns1" = Table.SelectColumns(#"Extrae ficheros de binario a tabla", {"Extracción ficheros WebApp"}),

    #"Expande datos de ficheros" = Table.ExpandTableColumn(#"Removed Other Columns1", "Extracción ficheros WebApp", Table.ColumnNames(FicheroMuestra)),
    #"Changed Type" = Table.TransformColumnTypes(#"Expande datos de ficheros",{{"FromDate", Int64.Type}, {"ToDate", Int64.Type}, {"Users", Int64.Type}, {"newUsers", Int64.Type}, {"Sessions", Int64.Type}, {"avgSessionDuration", type number}}, "en-US"),

// These 2 steps have to be customized in each file type (ie.: Futbol Femenino, LaLigaTV)
#"Added SuborigenId" = Table.AddColumn(#"Changed Type", "Suborigen_Id", each [ViewId] & "-Total"),
#"Added SuborigenName" = Table.AddColumn(#"Added SuborigenId", "Suborigen_Name", each [Source]),

    #"Elimina registros sin fecha" = Table.SelectRows(#"Added SuborigenName", each [ToDate] <> null and [ToDate] <> "")

in
    #"Elimina registros sin fecha";

shared #"GA-CombinedData-WithoutCountry-Week" = let
// Aquí combinaremos los datos de LaLigaTV y FutbolFemenino cuando se tengan

// Quito la col de fecha de la tabla #"GA-ADLS-WebApp-WithoutCountry-Week"

    #"Removed columns" = Table.RemoveColumns(#"GA-ADLS-WebApp-WithoutCountry-Week", "Date modified"),

    Source = Table.Combine({#"Removed columns"}), //  {#"GA-ADLS-WebApp-WithoutCountry-Week"}),
    #"Merged Queries" = Table.NestedJoin(Source,{"ToDate"},Fecha,{"Date_Id"},"Fecha",JoinKind.LeftOuter),
    #"Expanded Fecha" = Table.ExpandTableColumn(#"Merged Queries", "Fecha", {"Season_Id", "Week_Number", "Week_Id"}, {"Season_Id", "Week_Number", "Week_Id"})
in
    #"Expanded Fecha";

shared #"GA-CombinedData-WithoutCountry-Month" = let
// Aquí combinaremos los datos de LaLigaTV y FutbolFemenino cuando se tengan
    Source = Table.Combine({#"GA-ADLS-WebApp-WithoutCountry-Month"}),
    #"Merged Queries" = Table.NestedJoin(Source, {"ToDate"},Fecha,{"Date_Id"},"Fecha",JoinKind.LeftOuter),
    #"Expanded Fecha" = Table.ExpandTableColumn(#"Merged Queries", "Fecha", {"Month_Num", "Month_YYYYMM", "Year_Num"}, {"Month_Num", "Month_YYYYMM", "Year_Num"}),
    #"Renamed Columns" = Table.RenameColumns(#"Expanded Fecha",{{"Month_YYYYMM", "Month_Id"}})
in
    #"Renamed Columns";

shared #"GA-CombinedData-WithoutCountry-Season" = let
    Source = Table.Combine({#"GA-ADLS-WebApp-WithoutCountry-Season"}),
    #"Merged Queries" = Table.NestedJoin(Source, {"ToDate"},Fecha,{"Date_Id"},"Fecha",JoinKind.LeftOuter),
    #"Expanded Fecha" = Table.ExpandTableColumn(#"Merged Queries", "Fecha", {"Season_Id", "Week_Number", "Week_Id"}, {"Season_Id", "Week_Number", "Week_Id"})
in
    #"Expanded Fecha";

shared #"SN-LaLigaFollowers-Week" = let
    Source = Sql.Database(server_datawarehouse, bd_datawarehouse),

    dwh_LaLigaFollowers = Source{[Schema="dwh",Item="vFtFollowers_Week"]}[Data],

    #"Filtered Rows" = Table.SelectRows(dwh_LaLigaFollowers, each ([Entity_Code] = "LaLiga Santander")),
    #"Removed Columns" = Table.RemoveColumns(#"Filtered Rows",{"Sem_dIni", "Sem_dFin", "Entity_Code"}),
    #"Renamed Columns" = Table.RenameColumns(#"Removed Columns",{{"SemFechaIni_Id", "FromDate"}, {"SemFechaFin_Id", "ToDate"}}),
    #"Added Custom" = Table.AddColumn(#"Renamed Columns", "Custom", each [Source] & "-" & [ViewId]),
    #"Duplicated Column" = Table.DuplicateColumn(#"Added Custom", "Custom", "Custom - Copy"),
    #"Duplicated Column1" = Table.DuplicateColumn(#"Duplicated Column", "Custom", "Custom - Copy.1"),
    #"Removed Columns1" = Table.RemoveColumns(#"Duplicated Column1",{"ViewId"}),
    #"Renamed Columns1" = Table.RenameColumns(#"Removed Columns1",{{"Custom", "ViewId"}, {"Custom - Copy", "Suborigen_Id"}, {"Custom - Copy.1", "Suborigen_Name"}})
in
    #"Renamed Columns1";

shared #"SN-LaLigaFollowers-Month" = let
    Source = Sql.Database(server_datawarehouse, bd_datawarehouse),

    dwh_LaLigaFollowers = Source{[Schema="dwh",Item="vFtFollowers_Month"]}[Data],

    #"Filtered Rows" = Table.SelectRows(dwh_LaLigaFollowers, each ([Entity_Code] = "LaLiga Santander")),

    #"Removed Columns" = Table.RemoveColumns(#"Filtered Rows",{"Month_BeginDate", "Month_EndDate", "Entity_Code", "LastDateWithData"}),

    #"Renamed Columns" = Table.RenameColumns(#"Removed Columns",{{"MonthBeginDate_Id", "FromDate"}, {"MonthEndDate_Id", "ToDate"}}),
    #"Added Custom" = Table.AddColumn(#"Renamed Columns", "Custom", each [Source] & "-" & [ViewId]),
    #"Duplicated Column" = Table.DuplicateColumn(#"Added Custom", "Custom", "Custom - Copy"),
    #"Duplicated Column1" = Table.DuplicateColumn(#"Duplicated Column", "Custom", "Custom - Copy.1"),
    #"Removed Columns1" = Table.RemoveColumns(#"Duplicated Column1",{"ViewId"}),
    #"Renamed Columns1" = Table.RenameColumns(#"Removed Columns1",{{"Custom", "ViewId"}, {"Custom - Copy", "Suborigen_Id"}, {"Custom - Copy.1", "Suborigen_Name"}})
in
    #"Renamed Columns1";

shared #"GA+SN WithoutCountry-Week" = let
    Source = Table.Combine({#"GA-CombinedData-WithoutCountry-Week", #"SN-LaLigaFollowers-Week"})
in
    #"Source";

shared #"GA+SN WithoutCountry-Month" = let
    Source = Table.Combine({#"GA-CombinedData-WithoutCountry-Month", #"SN-LaLigaFollowers-Month"})
in
    Source;

shared #"GA+SN WithoutCountry-Season" = let
    Source = Table.Combine({#"GA-CombinedData-WithoutCountry-Season", #"SN-LaLigaFollowers-Week"})
in
    Source;

shared #"Fichero WebApp muestra con país" = let
    Source = Table.FromRecords(  
  
{  
    [FromDate = 20171211, ToDate = 20171217, ViewId = "76612905", Source = "Web España", CountryIsoCode = "AD"
    , Users = 268 as nullable number, newUsers = 154, Sessions = 466, avgSessionDuration = 243.87982832618025 ]
}  
  
)
in
    Source;

shared #"Extrae datos de fichero WebApp con país" = let
    Source = (#"Parámetro fichero WebApp muestra" as binary) => let
        Source = Csv.Document(#"Parámetro fichero WebApp muestra",[Delimiter="	", Columns=9, Encoding=65001, QuoteStyle=QuoteStyle.None]),
        #"Promoted Headers" = Table.PromoteHeaders(Source, [PromoteAllScalars=true])
    in
        #"Promoted Headers"
in
    Source;

[ Description = "Path to the datalake root folder where Google Analytics files are stored." ]
shared ADLS_Root = "https://ll1preunedlsdatalake.azuredatalakestore.net//model/googleanalytics" meta [IsParameterQuery=true, Type="Text", IsParameterQueryRequired=true];

shared #"GA LastUpdate" = let
    #"Calculated Latest" = List.Max(#"GA-ADLS-WebApp-WithoutCountry-Week"[Date modified]),
    #"Converted to Table" = #table(1, {{#"Calculated Latest"}}),
    #"Renamed Columns" = Table.RenameColumns(#"Converted to Table",{{"Column1", "LastUpdate"}}),
    #"Changed Type" = Table.TransformColumnTypes(#"Renamed Columns",{{"LastUpdate", type datetime}})
in
    #"Changed Type";