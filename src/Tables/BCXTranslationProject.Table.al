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
        }
        field(100; "No. Series"; Code[10])
        {
            Caption = 'No. Series';
            Editable = false;
            TableRelation = "No. Series";
        }
        field(110; OrginalAttr; Text[100])
        {
            Caption = 'OrginalAttr';
            Editable = false;
        }
        field(120; "NAV Version"; Option)
        {
            Caption = 'NAV Version';
            InitValue = 1;
            OptionCaption = 'Dynamics 365 Business Central';
            OptionMembers = "Dynamics 365 Business Central";
        }
        field(130; Status; Option)
        {
            Caption = 'Status';
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
        BCXTranslationSetup: Record "BCX Translation Setup";
    begin
        "Created By" := CopyStr(UserId(), 1, MaxStrLen(("Created By")));
        "Creation Date" := Today();
        BCXTranslationSetup.Get();
        if "Source Language" = '' then
            Validate("Source Language", BCXTranslationSetup."Default Source Language code");

    end;

    trigger OnDelete()
    var
        BCXBaseTranslationTarget: Record "BCX Base Translation Target";
        BCXTargetLanguage: Record "BCX Target Language";
        BCXTranslationNote: Record "BCX Translation Note";
        BCXTranslationSource: Record "BCX Translation Source";
        BCXTranslationTarget: Record "BCX Translation Target";
        BCXTranslationTerm: Record "BCX Translation Term";
    begin
        BCXTranslationSource.SetRange("Project Code", "Project Code");
        BCXTranslationSource.DeleteAll(false);

        BCXTranslationTarget.SetRange("Project Code", "Project Code");
        BCXTranslationTarget.DeleteAll(false);

        BCXTargetLanguage.SetRange("Project Code", "Project Code");
        BCXTargetLanguage.DeleteAll(false);

        BCXBaseTranslationTarget.SetRange("Project Code", "Project Code");
        BCXBaseTranslationTarget.DeleteAll(false);

        BCXTranslationNote.SetRange("Project Code", "Project Code");
        BCXTranslationNote.DeleteAll(false);

        BCXTranslationTerm.SetRange("Project Code", "Project Code");
        BCXTranslationTerm.DeleteAll(false);
    end;
}