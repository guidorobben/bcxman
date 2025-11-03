table 78611 "BCX Base Translation Notes"
{
    Caption = 'BAC Base Translation Notes';
    DataClassification = AccountData;

    fields
    {
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
        field(30; From; Text[250])
        {
            Caption = 'From';
            DataClassification = AccountData;
        }
        field(40; Annotates; Text[50])
        {
            Caption = 'Annotates';
            DataClassification = AccountData;
        }
        field(50; Priority; Text[10])
        {
            Caption = 'Priority';
            DataClassification = AccountData;
        }
        field(60; Note; Text[250])
        {
            Caption = 'Note';
            DataClassification = AccountData;
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