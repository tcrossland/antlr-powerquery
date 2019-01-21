section Section1;

shared ReportsDefinition = let
    Source = Table.FromRows(
        Json.Document(
            Binary.Decompress(
                Binary.FromText("+x=", BinaryEncoding.Base64),
                Compression.Deflate
            )
        ),
        let _t = ((type text) meta [Serialized.Text = true]) 
        in type table 
        [
            Report_Id = _t,
            ViewId = _t,
            Segment = _t,
            #"Flag count to global" = _t,
            #"Grupo audiencia" = _t,
            Suborigen_Name = _t
        ]
    ),
    #"Added Custom" = Table.AddColumn(Source, "Suborigen_Id", each [ViewId] & "-" & [Segment])
in
    #"Added Custom";
