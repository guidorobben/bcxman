table 78600 "BCX Translation Project"
{
    Caption = 'Translation Project Name';
    DataCaptionFields = "Project Code", "Project Name";
    DataClassification = SystemMetadata;

    fields
    {
        field(10; "Project Code"; Code[20])
        {
            Caption = 'Project Code';
            DataClassification = SystemMetadata;

        }
        field(20; "Project Name"; Text[100])
        {
            Caption = 'Project Name';
            DataClassification = AccountData;
        }
        field(30; "Source Language"; Code[10])
        {
            Caption = 'Source Language';
            DataClassification = AccountData;
            TableRelation = Language;
            trigger OnValidate()
            var
                Language: Record Language;
            begin
                if Language.Get("Source Language") then begin
                    Language.TestField("BCX ISO code");
                    "Source Language ISO code" := Language."BCX ISO code"
                end else
                    Clear("Source Language ISO code");
            end;
        }
        field(32; "Target Language"; Text[10])
        {
            Caption = 'Target Language';
            DataClassification = AccountData;
        }

        field(35; "Source Language ISO code"; Text[10])
        {
            Caption = 'Source Language';
            DataClassification = AccountData;
            Editable = false;
        }
        field(40; "Creation Date"; Date)
        {
            Caption = 'Creation Date';
            DataClassification = AccountData;
            Editable = false;
        }
        field(50; "Created By"; Text[100])
        {
            Caption = 'Created By';
            DataClassification = AccountData;
            Editable = false;
        }
        field(60; "Xml Version"; Text[250])
        {
            Caption = 'Xml Version';
            DataClassification = AccountData;
        }
        field(70; "Xliff Version"; Text[250])
        {
            Caption = 'Xliff Version';
            DataClassification = AccountData;

        }
        field(80; "File Datatype"; Text[250])
        {
            Caption = 'File Datatype';
            DataClassification = AccountData;

        }
        field(90; "File Name"; Text[250])
        {
            Caption = 'File Name';
            DataClassification = SystemMetadata;
        }
        field(100; "No. Series"; Code[10])
        {
            Caption = 'No. Series';
            DataClassification = SystemMetadata;
            Editable = false;
            TableRelation = "No. Series";
        }
        field(110; OrginalAttr; Text[100])
        {
            Caption = 'OrginalAttr';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(120; "NAV Version"; Option)
        {
            Caption = 'NAV Version';
            DataClassification = SystemMetadata;
            InitValue = 1;
            OptionCaption = 'Dynamics 365 Business Central';
            OptionMembers = "Dynamics 365 Business Central";
        }
        field(130; Status; Option)
        {
            Caption = 'Status';
            DataClassification = SystemMetadata;
            OptionCaption = 'Open,Released,Closed';
            OptionMembers = Open,Released,Closed;
        }
        field(140; "Base Translation Imported"; Boolean)
        {
            Caption = 'Base Translation Imported';
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Project Code")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "Project Code", "Project Name") { }
    }

    trigger OnInsert()
    var
        TransSetup: Record "BCX Translation Setup";
    begin
        "Created By" := CopyStr(UserId(), 1, MaxStrLen(("Created By")));
        "Creation Date" := Today;
        TransSetup.Get();
        if "Source Language" = '' then
            Validate("Source Language", TransSetup."Default Source Language code");

    end;

    trigger OnDelete()
    var
        TargetBaseLanguage: Record "BCX Base Translation Target";
        TargetLanguage: Record "BCX Target Language";
        TranNote: Record "BCX Translation Notes";
        TransSource: Record "BCX Translation Source";
        TransTarget: Record "BCX Translation Target";
        TransTerm: Record "BCX Translation Term";
    begin
        TransSource.SetRange("Project Code", "Project Code");
        TransSource.DeleteAll();
        TransTarget.SetRange("Project Code", "Project Code");
        TransTarget.DeleteAll();
        TargetLanguage.SetRange("Project Code", "Project Code");
        TargetLanguage.DeleteAll();
        TargetBaseLanguage.SetRange("Project Code", "Project Code");
        TargetBaseLanguage.DeleteAll();
        TranNote.SetRange("Project Code", "Project Code");
        TranNote.DeleteAll();
        TransTerm.SetRange("Project Code", "Project Code");
        TransTerm.DeleteAll();
    end;

}