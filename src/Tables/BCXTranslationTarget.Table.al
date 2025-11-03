table 78602 "BCX Translation Target"
{
    Caption = 'Translation Target';
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
            Editable = false;
        }
        field(20; "Trans-Unit Id"; Text[250])
        {
            Caption = 'Trans-Unit Id';
            Editable = false;
        }
        field(30; "Target Language"; Code[10])
        {
            Caption = 'Target Language';
            Editable = false;
        }
        field(40; "Target Language ISO code"; Text[10])
        {
            Caption = 'Target Language ISO code';
            Editable = false;
        }

        field(50; Source; Text[2048])
        {
            Caption = 'Source';
            Editable = false;
        }
        field(60; Target; Text[2048])
        {
            Caption = 'Target';

            trigger OnValidate()
            begin
                UpdateAllTargetInstances();
            end;
        }
        field(70; Translate; Boolean)
        {
            Caption = 'Translate';
            InitValue = true;
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
        field(130; Occurrencies; Integer)
        {
            CalcFormula = count("BCX Translation Target" where(Source = field(Source), "Target Language" = field("Target Language")));
            Caption = 'Occurrencies';
            FieldClass = FlowField;
        }
        field(140; "Field Name"; Text[2048])
        {
            Caption = 'Field Name';
        }

    }

    keys
    {
        key(PK; "Project Code", "Target Language", "Trans-Unit Id")
        {
            Clustered = true;
        }
    }
    procedure UpdateAllTargetInstances()
    var
        TransTarget: Record "BCX Translation Target";
        Instances: Integer;
        QuestionTxt: Label 'Copy the Target to all other instances?';
    begin
        TransTarget.Copy(Rec);
        TransTarget.SetRange(Source, Source);
        TransTarget.SetRange("Target Language", "Target Language");
        Instances := TransTarget.Count();
        if Target = '' then
            exit;
        if Instances > 1 then begin
            if CurrFieldNo > 0 then
                if not Confirm(QuestionTxt) then
                    exit;
            TransTarget.SetFilter("Trans-Unit Id", '<>%1', "Trans-Unit Id");
            TransTarget.ModifyAll(Target, Target);
            TransTarget.ModifyAll(Translate, false);
        end;
        if Target <> '' then
            Translate := false;
    end;
}