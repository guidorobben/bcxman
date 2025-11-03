table 78603 "BCX Target Language"
{
    Caption = 'Target Language';
    DataCaptionFields = "Project Code", "Target Language";
    DataClassification = SystemMetadata;

    fields
    {
        field(10; "Project Code"; Code[20])
        {
            Caption = 'Project Code';
            DataClassification = AccountData;
            Editable = false;
            TableRelation = "BCX Translation Project";
        }
        field(20; "Project Name"; Text[100])
        {
            CalcFormula = lookup("BCX Translation Project"."Project Name" where("Project Code" = field("Project Code")));
            Caption = 'Project Name';
            Editable = false;
            FieldClass = FlowField;
        }

        field(30; "Source Language"; Code[10])
        {
            Caption = 'Source Language';
            DataClassification = AccountData;
            Editable = false;
            TableRelation = Language;
        }
        field(35; "Source Language ISO code"; Text[10])
        {
            Caption = 'Source Language ISO code';
            DataClassification = AccountData;
            Editable = false;
        }
        field(40; "Target Language"; Code[10])
        {
            Caption = 'Target Language';
            DataClassification = AccountData;
            TableRelation = Language;
            trigger OnValidate()
            var
                Language: Record Language;
            begin
                if Language.Get("Target Language") then begin
                    Language.TestField("BCX ISO code");
                    "Target Language ISO code" := Language."BCX ISO code"
                end else
                    Clear("Target Language ISO code");
            end;
        }
        field(45; "Target Language ISO code"; Text[10])
        {
            Caption = 'Target Language ISO code';
            DataClassification = AccountData;
            Editable = false;
        }
        field(50; "File Name"; Text[250])
        {
            Caption = 'File Name';
            DataClassification = SystemMetadata;
        }
        field(60; "Equivalent Language"; Code[10])
        {
            Caption = 'Equivalent Language';
            DataClassification = AccountData;
            TableRelation = Language;
            trigger OnValidate()
            var
                Language: Record Language;
            begin
                if Language.Get("Equivalent Language") then begin
                    Language.TestField("BCX ISO code");
                    "Equivalent Language ISO code" := Language."BCX ISO code"
                end else
                    Clear("Equivalent Language ISO code");
            end;
        }
        field(65; "Equivalent Language ISO code"; Text[10])
        {
            Caption = 'Equivalent Language ISO code';
            DataClassification = AccountData;
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Project Code", "Target Language")
        {
            Clustered = true;
        }
    }
}