table 78608 "BCX User Access"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(10; "User Id"; Text[50])
        {
            Caption = 'User Id';
            DataClassification = SystemMetadata;
        }
        field(20; "Project Code"; Code[20])
        {
            Caption = 'Project Code';
            DataClassification = SystemMetadata;
            TableRelation = "BCX Translation Project";
        }
        field(30; "Project Name"; Text[100])
        {
            CalcFormula = lookup("BCX Translation Project"."Project Name" where("Project Code" = field("Project Code")));
            Caption = 'Project Name';
            FieldClass = FlowField;
        }
        field(40; "User Name"; Text[100])
        {
            CalcFormula = lookup(User."Full Name" where("User Name" = field("User Id")));
            Caption = 'User Name';
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(PK; "Project Code", "User Id")
        {
            Clustered = true;
        }

    }
    trigger OnInsert()
    var
        ErrorTxt: Label 'Creating an entry with your own User ID will lock you out of this page';

    begin
        if "User Id" = UserId() then
            Error(ErrorTxt);
    end;
}