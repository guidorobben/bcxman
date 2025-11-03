table 78607 "BCX Gen. Translation Term"
{
    Caption = 'General Translation Term';
    DataCaptionFields = "Target Language";
    DataClassification = AccountData;

    fields
    {
        field(10; "Project Code"; Code[10])
        {
            Caption = 'Project Code';
            DataClassification = AccountData;
            Editable = false;
        }
        field(20; "Target Language"; Code[10])
        {
            Caption = 'Target Language';
            DataClassification = AccountData;
            Editable = false;
        }
        field(30; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = AccountData;
        }
        field(40; Term; Text[250])
        {
            Caption = 'Term';
            DataClassification = AccountData;
        }
        field(50; Translation; Text[250])
        {
            Caption = 'Translation';
            DataClassification = AccountData;
        }
        field(60; "Apply Pre-Translation"; Boolean)
        {
            Caption = 'Apply Pre-Translation';
            DataClassification = AccountData;
        }
    }

    keys
    {
        key(PK; "Line No.")
        {
            Clustered = true;
        }
        key(Language; "Target Language", "Line No.") { }
    }

}