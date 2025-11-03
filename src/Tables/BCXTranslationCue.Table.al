table 78609 "BCX Translation Cue"
{
    Caption = 'Translate Cue';
    DataClassification = ToBeClassified;

    fields
    {
        field(10; "Primary Key"; Code[10])
        {
            AllowInCustomizations = AsReadOnly;
            Caption = 'Primary Key';
        }
        field(20; "Open Projects"; Integer)
        {
            CalcFormula = count("BCX Translation Project" where(Status = const(Open), "Project Code" = field("Project Filter")));
            Caption = 'Open Projects';
            Editable = false;
            FieldClass = FlowField;
        }
        field(30; "Released Projects"; Integer)
        {
            CalcFormula = count("BCX Translation Project" where(Status = const(Released), "Project Code" = field("Project Filter")));
            Caption = 'Released Projects';
            Editable = false;
            FieldClass = FlowField;
        }
        field(40; "Finished Projects"; Integer)
        {
            CalcFormula = count("BCX Translation Project" where(Status = const(Released), "Project Code" = field("Project Filter")));
            Caption = 'Finished Projects';
            Editable = false;
            FieldClass = FlowField;
        }
        field(50; "Projects this Month"; Integer)
        {
            CalcFormula = count("BCX Translation Project" where("Creation Date" = field("Month Date Filter"), "Project Code" = field("Project Filter")));
            Caption = 'Projects this Month';
            Editable = false;
            FieldClass = FlowField;
        }
        field(60; "Total Projects"; Integer)
        {
            CalcFormula = count("BCX Translation Project" where("Project Code" = field("Project Filter")));
            Caption = 'Total Projects';
            Editable = false;
            FieldClass = FlowField;
        }
        field(100; "Month Date Filter"; Date)
        {
            Caption = 'Month Date Filter';
            FieldClass = FlowFilter;
        }
        field(110; "Project Filter"; Text[250])
        {
            Caption = 'Project Filter';
            FieldClass = FlowFilter;
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }
}