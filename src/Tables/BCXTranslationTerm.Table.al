table 78605 "BCX Translation Term"
{
    Caption = 'Translation Term';
    DataCaptionFields = "Project Code", "Target Language";
    DataClassification = AccountData;

    fields
    {
        field(10; "Project Code"; Code[10])
        {
            Caption = 'Project Code';
            Editable = false;
        }
        field(20; "Target Language"; Code[10])
        {
            Caption = 'Target Language';
            Editable = false;
        }
        field(30; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(40; Term; Text[250])
        {
            Caption = 'Term';
        }
        field(50; Translation; Text[250])
        {
            Caption = 'Translation';
        }
        field(60; "Apply Pre-Translation"; Boolean)
        {
            Caption = 'Apply Pre-Translation';
        }
    }

    keys
    {
        key(PK; "Project Code", "Target Language", "Line No.")
        {
            Clustered = true;
        }
    }
}