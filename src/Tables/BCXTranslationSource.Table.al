table 78601 "BCX Translation Source"
{
    Caption = 'Translation Source';
    DataClassification = AccountData;

    fields
    {
        field(5; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = SystemMetadata;
        }
        field(10; "Project Code"; Code[20])
        {
            Caption = 'Project Code';
            DataClassification = AccountData;
        }
        field(20; "Trans-Unit Id"; Text[250])
        {
            Caption = 'Trans-Unit Id';
            DataClassification = AccountData;
        }
        field(50; Source; Text[2048])
        {
            Caption = 'Source';
            DataClassification = AccountData;
        }
        field(80; "size-unit"; Text[10])
        {
            Caption = 'size-unit';
            DataClassification = AccountData;
        }
        field(90; TranslateAttr; Text[10])
        {
            Caption = 'TranslateAttr';
            DataClassification = AccountData;
        }
        field(100; "xml:space"; Text[10])
        {
            Caption = 'xml:space';
            DataClassification = AccountData;
        }
        field(110; "Max Width"; Text[10])
        {
            Caption = 'Max Width';
            DataClassification = AccountData;
        }
        field(120; "al-object-target"; Text[100])
        {
            Caption = 'al-object-target';
            DataClassification = AccountData;
        }
        field(140; "Field Name"; Text[2048])
        {
            Caption = 'Field Name';
            DataClassification = AccountData;

        }
    }

    keys
    {
        key(PK; "Project Code", "Trans-Unit Id")
        {
            Clustered = true;
        }
    }
}