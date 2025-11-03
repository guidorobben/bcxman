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
        }
        field(20; "Trans-Unit Id"; Text[250])
        {
            Caption = 'Trans-Unit Id';
        }
        field(50; Source; Text[2048])
        {
            Caption = 'Source';
        }
        field(80; "size-unit"; Text[10])
        {
            Caption = 'size-unit';
        }
        field(90; TranslateAttr; Text[10])
        {
            Caption = 'TranslateAttr';
        }
        field(100; "xml:space"; Text[10])
        {
            Caption = 'xml:space';
        }
        field(110; "Max Width"; Text[10])
        {
            Caption = 'Max Width';
        }
        field(120; "al-object-target"; Text[100])
        {
            Caption = 'al-object-target';
        }
        field(140; "Field Name"; Text[2048])
        {
            Caption = 'Field Name';

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