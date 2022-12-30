section Section1;

shared #"GA-ADLS-WebApp-WithCountry-Week" = let
    S1 = DataLake.Contents("https://ll1preunedlsdatalake.azuredatalakestore.net//model/googleanalytics/digitalaudienceweekly/usersSessionsByCountry"),
    #"Extracted" = Table.AddColumn(S1, "Extracción ficheros WebApp", each #"ExtractData"([Content]))
in
    #"Extracted";

shared #"ExtractData" = let
    S2 = (#"Content" as binary) => let
        S3 = Csv.Document(#"Content",[Delimiter=","]),
        #"Promoted Headers" = Table.PromoteHeaders(S3, [PromoteAllScalars=true])
    in
        #"Promoted Headers"
in
    S2;

