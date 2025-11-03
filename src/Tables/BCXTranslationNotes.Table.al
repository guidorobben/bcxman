table 78604 "BCX Translation Note"
{
    Caption = 'BCX Translation Notes';
    DataClassification = AccountData;

    fields
    {
        field(10; "Project Code"; Code[20])
        {
            Caption = 'Project Code';
        }

        field(20; "Trans-Unit Id"; Text[250])
        {
            Caption = 'Trans-Unit Id';
        }
        field(30; From; Text[250])
        {
            Caption = 'From';
        }
        field(40; Annotates; Text[50])
        {
            Caption = 'Annotates';
        }
        field(50; Priority; Text[10])
        {
            Caption = 'Priority';
        }
        field(60; Note; Text[2048])
        {
            Caption = 'Note';
        }
    }

    keys
    {
        key(PK; "Project Code", "Trans-Unit Id", From)
        {
            Clustered = true;
        }
    }
}