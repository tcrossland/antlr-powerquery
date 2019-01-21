section Section1;

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

shared ReportsDefinition = 
    let _t = ((type text) meta [Serialized.Text = true]) in type table [Report_Id = _t, ViewId = _t, Segment = _t, #"Flag count to global" = _t, #"Grupo audiencia" = _t, Suborigen_Name = _t])
in #"Added Custom";

[ Description = "Subfolder for WebApp-WithCountry-Week files. Must begin with a ""/""." ]
shared #"ADLS_WebApp-WithCountry-Week" = "/digitalaudienceweekly/usersSessionsByCountry" meta [IsParameterQuery=true, Type="Text", IsParameterQueryRequired=true];

shared Reports = 
    let _t = ((type text) meta [Serialized.Text = true]) in type table [Report_Id = _t, Report_Name = _t, Report_Logo = _t, Report_Order = _t])
in #"Replaced Value";

[ Description = "Subfolder for WebApp-WithCountry-Month files. Must begin with a ""/""." ]
shared #"ADLS_WebApp-WithCountry-Month" = "/digitalaudiencemonthly/usersSessionsByCountry" meta [IsParameterQuery=true, Type="Text", IsParameterQueryRequired=true];

[ Description = "Subfolder for WebApp-WithCountry-Season files. Must begin with a ""/""." ]
shared #"ADLS_WebApp-WithCountry-Season" = "/digitalaudienceseasonly/usersSessionsByCountry" meta [IsParameterQuery=true, Type="Text", IsParameterQueryRequired=true];

[ Description = "Subfolder for LaLigaTV-WithCountry-Season files. Must begin with a ""/""." ]
shared #"ADLS_LaLigaTV-WithCountry-Season" = "/digitalaudienceseasonly/laligaTVByCountry" meta [IsParameterQuery=true, Type="Text", IsParameterQueryRequired=true];

[ Description = "Subfolder for FutbolFemenino-WithCountry-Season files. Must begin with a ""/""." ]
shared #"ADLS_FutbolFemenino-WithCountry-Season" = "/digitalaudienceseasonly/futbolFemeninoByCountry" meta [IsParameterQuery=true, Type="Text", IsParameterQueryRequired=true];

[ Description = "Subfolder for WebApp-WithoutCountry-Week files. Must begin with a ""/""." ]
shared #"ADLS_WebApp-WithoutCountry-Week" = "/digitalaudienceweekly/usersSessions" meta [IsParameterQuery=true, Type="Text", IsParameterQueryRequired=true];

[ Description = "Subfolder for WebApp-WithoutCountry-Month files. Must begin with a ""/""." ]
shared #"ADLS_WebApp-WithoutCountry-Month" = "/digitalaudiencemonthly/usersSessions" meta [IsParameterQuery=true, Type="Text", IsParameterQueryRequired=true];

[ Description = "Subfolder for WebApp-WithoutCountry-Season files. Must begin with a ""/""." ]
shared #"ADLS_WebApp-WithoutCountry-Season" = "/digitalaudienceseasonly/usersSessions" meta [IsParameterQuery=true, Type="Text", IsParameterQueryRequired=true];

[ Description = "For internal use. Keep it empty." ]
shared #"Parámetro fichero WebApp muestra" = #"Fichero WebApp muestra sin país" meta [IsParameterQuery=true, BinaryIdentifier=#"Fichero WebApp muestra sin país", Type="Binary", IsParameterQueryRequired=true];

[ Description = "Path to the datalake root folder where Google Analytics files are stored." ]
shared ADLS_Root = "https://ll1preunedlsdatalake.azuredatalakestore.net//model/googleanalytics" meta [IsParameterQuery=true, Type="Text", IsParameterQueryRequired=true];
